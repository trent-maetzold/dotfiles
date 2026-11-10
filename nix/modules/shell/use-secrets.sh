# shellcheck shell=bash
# direnv: `use secrets [file]` exports secrets listed in file (default .env.secrets),
# one NAME=<source> per line, so they reach only that directory's environment:
#
#   DB_PASSWORD=ksm:keeper://<record-uid>/field/password   Keeper Secrets Manager (KSM_CONFIG_FILE, else ksm's profile)
#   API_TOKEN=keeper:<record-uid>                          Keeper Commander (needs a persistent login), password field
#   GH_TOKEN=rbw:github                                    Bitwarden via rbw: password, or rbw:<entry>#<field>
#   N8N_KEY=sops:secrets.yaml#integrations/n8n/key         sops file, key path split on /
#   SMTP_PASS=age:secrets/smtp.age                         age/agenix file ($AGE_IDENTITY, default ~/.ssh/id_ed25519)
#   JIRA_TOKEN=file:/run/user/1000/secrets/JIRA_API_TOKEN  any decrypted file, e.g. sops-nix or agenix paths
#
# Values are exported as-is, never eval'd. Lookups use stdin </dev/null, so a
# locked vault fails instead of prompting: unlock it first (rbw unlock, keeper login).
use_secrets() {
  local file=${1:-.env.secrets} line name ref value path
  local -a ksm=()
  watch_file "$file"
  if [[ ! -r $file ]]; then
    log_error "use secrets: $file not found"
    return 1
  fi
  while IFS= read -r line || [[ -n $line ]]; do
    [[ $line =~ ^[[:space:]]*(#|$) ]] && continue
    name=${line%%=*} ref=${line#*=}
    if [[ ! $name =~ ^[A-Za-z_][A-Za-z0-9_]*$ || $line != *=* ]]; then
      log_error "use secrets: bad line: $line"
      return 1
    fi
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
    esac || {
      log_error "use secrets: $name: cannot read $ref"
      return 1
    }
    export "$name=$value"
  done <"$file"
  ((${#ksm[@]} == 0)) || _use_secrets_ksm "${ksm[@]}"
}

# One ksm process for every ksm: line: `ksm exec` swaps keeper:// values in its
# environment for the secrets, and env -0 hands them back NUL-separated.
_use_secrets_ksm() {
  local out pair want
  local -a config=()
  # The ksm CLI reads a base64 config from KSM_CONFIG; Keeper SDKs read the JSON file.
  [[ -r ${KSM_CONFIG_FILE:-} ]] && config=("KSM_CONFIG=$(base64 -w0 <"$KSM_CONFIG_FILE")")
  out=$(mktemp -p "${XDG_RUNTIME_DIR:-/tmp}") || return 1
  if ! env "${config[@]}" "$@" ksm exec -- env -0 >"$out" </dev/null; then
    rm -f "$out"
    log_error "use secrets: ksm failed"
    return 1
  fi
  # shellcheck disable=SC2094 # $out is removed only after the loop reads it
  while IFS= read -r -d '' pair; do
    for want in "$@"; do
      [[ ${pair%%=*} == "${want%%=*}" ]] || continue
      if [[ ${pair#*=} == keeper://* ]]; then
        log_error "use secrets: ${want%%=*}: ksm did not resolve ${pair#*=}"
        rm -f "$out"
        return 1
      fi
      export "${pair?}"
    done
  done <"$out"
  rm -f "$out"
}
