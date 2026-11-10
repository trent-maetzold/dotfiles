# secrets-env [file]: read NAME=<source> lines (default .env.secrets) and print
# `export NAME=<value>` lines, shell-quoted, for a devShell shellHook to eval:
#
#   DB_PASSWORD=ksm:keeper://<record-uid>/field/password   Keeper Secrets Manager (KSM_CONFIG_FILE, else ksm's profile)
#   API_TOKEN=keeper:<record-uid>                          Keeper Commander (needs a persistent login), password field
#   GH_TOKEN=rbw:github                                    Bitwarden via rbw: password, or rbw:<entry>#<field>
#   N8N_KEY=sops:secrets.yaml#integrations/n8n/key         sops file, key path split on /
#   SMTP_PASS=age:secrets/smtp.age                         age/agenix file ($AGE_IDENTITY, default ~/.ssh/id_ed25519)
#   JIRA_TOKEN=file:/run/user/1000/secrets/JIRA_API_TOKEN  any decrypted file, e.g. sops-nix or agenix paths
#
# Relative paths resolve against the current directory. Vault CLIs come from
# PATH. Lookups get stdin </dev/null, so a locked vault fails instead of
# prompting: unlock it first (rbw unlock, keeper login). Prints nothing unless
# every secret resolved.

die() {
  echo "secrets-env: $*" >&2
  exit 1
}

file=${1:-.env.secrets}
[[ -r $file ]] || die "$file not found"

declare -A values=()
names=()
ksm=()
while IFS= read -r line || [[ -n $line ]]; do
  [[ $line =~ ^[[:space:]]*(#|$) ]] && continue
  name=${line%%=*} ref=${line#*=}
  [[ $line == *=* && $name =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || die "bad line: $line"
  names+=("$name")
  case $ref in
    ksm:*)
      ksm+=("$name=${ref#ksm:}")
      continue
      ;;
    keeper:*) value=$(keeper get "${ref#keeper:}" --format password </dev/null) ;;
    rbw:*)
      ref=${ref#rbw:}
      if [[ $ref == *'#'* ]]; then
        value=$(rbw get --field "${ref#*#}" "${ref%%#*}" </dev/null)
      else
        value=$(rbw get "$ref" </dev/null)
      fi
      ;;
    sops:*)
      ref=${ref#sops:} path=${ref#*#}
      value=$(sops decrypt --extract "[\"${path//\//\"][\"}\"]" "${ref%%#*}" </dev/null)
      ;;
    age:*) value=$(age --decrypt --identity "${AGE_IDENTITY:-$HOME/.ssh/id_ed25519}" "${ref#age:}" </dev/null) ;;
    file:*) value=$(<"${ref#file:}") ;;
    *) false ;;
  esac || die "$name: cannot read $ref"
  values[$name]=$value
done <"$file"

# One ksm process for every ksm: line: `ksm exec` swaps keeper:// values in its
# environment for the secrets, and env -0 hands them back NUL-separated.
if ((${#ksm[@]})); then
  config=()
  # The ksm CLI reads a base64 config from KSM_CONFIG; Keeper SDKs read the JSON file.
  if [[ -r ${KSM_CONFIG_FILE:-} ]]; then config=("KSM_CONFIG=$(base64 -w0 <"$KSM_CONFIG_FILE")"); fi
  out=$(mktemp -p "${XDG_RUNTIME_DIR:-/tmp}")
  trap 'rm -f -- "$out"' EXIT
  env "${config[@]}" "${ksm[@]}" ksm exec -- env -0 >"$out" </dev/null || die "ksm failed"
  while IFS= read -r -d '' pair; do
    for want in "${ksm[@]}"; do
      [[ ${pair%%=*} == "${want%%=*}" ]] || continue
      [[ ${pair#*=} != keeper://* ]] || die "${want%%=*}: ksm did not resolve ${pair#*=}"
      values[${pair%%=*}]=${pair#*=}
    done
  done <"$out"
fi

for name in "${names[@]}"; do
  [[ -v values[$name] ]] || die "$name: no value"
  printf 'export %s=%q\n' "$name" "${values[$name]}"
done
