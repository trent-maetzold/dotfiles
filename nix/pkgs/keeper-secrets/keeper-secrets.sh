# keeper-secrets USER MANIFEST (as root): fetch every secret in MANIFEST with
# USER's Keeper Commander session into a new directory, set owner/group/mode
# per secret, then repoint /run/keeper-secrets at it, like agenix's
# /run/agenix. Nothing changes unless every secret resolved. Never prompts:
# log in first with keeper-secrets-login.
user=$1 manifest=$2
root=/run/keeper-secrets.d

mkdir -p "$root"
chmod 0751 "$root"
new=$(mktemp -d "$root/gen.XXXXXX")
trap 'rm -rf -- "$new"' EXIT
chown "$user" "$new"

home=$(getent passwd "$user" | cut -d: -f6)
# File storage: there's no OS keychain for root-launched or boot-time runs.
runuser -u "$user" -- env HOME="$home" KEEPER_CONFIG_STORAGE=file \
  "$PYTHON" "$FETCH" "$manifest" "$new" </dev/null

chown root:root "$new"
chmod 0751 "$new"
jq -r 'to_entries[] | [.key, .value.owner, .value.group, .value.mode] | @tsv' "$manifest" |
  while IFS=$'\t' read -r name owner group mode; do
    chown "$owner:$group" "$new/$name"
    chmod "$mode" "$new/$name"
  done

ln -sfn "$new" /run/keeper-secrets.tmp
mv -T /run/keeper-secrets.tmp /run/keeper-secrets
trap - EXIT
for old in "$root"/gen.*; do
  [[ $old == "$new" ]] || rm -rf -- "$old"
done
