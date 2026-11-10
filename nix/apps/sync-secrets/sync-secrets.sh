# sync-secrets [DIR]: copy each NAME=<source> line of DIR/secrets.sources into
# DIR/secrets.yaml as the sops key NAME, then commit DIR if it changed.
# Sources use secrets-env syntax (keeper:<uid>[#field], ksm:keeper://..., rbw:...).
cd "${1:-.}"
export SOPS_AGE_KEY_FILE=${SOPS_AGE_KEY_FILE:-$HOME/.config/age/keys.txt}

# Keeper: log in once (turning on persistent login) if the saved session expired.
if grep -q '=keeper:' secrets.sources && ! keeper whoami </dev/null >/dev/null 2>&1; then
  keeper this-device register
  keeper this-device persistent-login on
fi

# Values stay in this process: secrets-env prints exports, eval sets them here.
exports=$(secrets-env secrets.sources)
eval "$exports"
while IFS= read -r name; do
  sops set secrets.yaml "[\"$name\"]" "$(printf '%s' "${!name}" | jq -Rs .)"
done < <(sed -nE 's/^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)=.*/\1/p' secrets.sources)

if git diff --quiet -- secrets.yaml; then
  echo "sync-secrets: no changes"
else
  git commit -qm "sync-secrets" -- secrets.yaml secrets.sources
  echo "sync-secrets: committed; update the flake input that points here"
fi
