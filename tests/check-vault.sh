#!/usr/bin/env bash
# Needs bash, rage, sops and sops-install-secrets. Uses only disposable keys.
set -euo pipefail
repo=$(cd "$(dirname "$0")/.." && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

rage-keygen -o "$work/key" >/dev/null 2>&1
rage-keygen -o "$work/wrong-key" >/dev/null 2>&1
recipient=$(rage-keygen -y "$work/key")
printf 'token: test-token-not-a-real-secret\n' |
  sops --encrypt --age "$recipient" --input-type yaml --output-type yaml /dev/stdin >"$work/secrets.yaml"
mkdir "$work/bin"
printf '#!%s\n' "$(command -v bash)" >"$work/bin/rbw"
cat >>"$work/bin/rbw" <<'MOCK'
set -eu
case "$1" in
  unlocked) test "$TEST_UNLOCKED" = yes ;;
  get) test "$2" = age-master; cat "$TEST_KEY" ;;
  *) exit 1 ;;
esac
MOCK
chmod +x "$work/bin/rbw"
export PATH="$work/bin:$PATH" TEST_KEY="$work/key" TEST_UNLOCKED=no

check() {
  bash -euo pipefail "$repo/nix/lib/check-vault.sh" "$1" >"$work/stdout" 2>"$work/stderr"
}
if check "$work/secrets.yaml"; then echo 'Locked vault was accepted' >&2; exit 1; fi
grep -q 'rbw unlock' "$work/stderr"

export TEST_UNLOCKED=yes
check "$work/secrets.yaml"
test ! -s "$work/stdout"

# A valid caller identity must not bypass a wrong/missing Bitwarden key.
SOPS_AGE_KEY=$(<"$work/key")
export SOPS_AGE_KEY TEST_KEY="$work/wrong-key"
if check "$work/secrets.yaml"; then echo 'Wrong vault key was accepted' >&2; exit 1; fi
export TEST_KEY="$work/missing-key"
if check "$work/secrets.yaml"; then echo 'Missing vault key was accepted' >&2; exit 1; fi
export TEST_KEY="$work/key"
printf 'not a sops document\n' >"$work/invalid.yaml"
if check "$work/invalid.yaml"; then echo 'Invalid secrets file was accepted' >&2; exit 1; fi
test ! -s "$work/stdout"
echo 'Vault gate: locked, unlocked, wrong key, missing key and invalid input passed.'

# Exercise sops-nix's actual installer with the same command-only key setup.
unset SOPS_AGE_KEY
export SOPS_AGE_KEY_CMD='rbw get age-master' XDG_RUNTIME_DIR="$work"
cat >"$work/manifest.json" <<EOF
{
  "userMode": true,
  "ageKeyFile": "/dev/null",
  "secretsMountPoint": "$work/secrets.d",
  "symlinkPath": "$work/secrets",
  "secrets": [{
    "name": "token", "key": "token", "format": "yaml", "mode": "0400",
    "path": "$work/secrets/token", "sopsFile": "$work/secrets.yaml"
  }]
}
EOF
sops-install-secrets "$work/manifest.json"
test "$(<"$work/secrets/token")" = test-token-not-a-real-secret
test "$(stat -c %a "$work/secrets/token")" = 400
if grep -q 'AGE-SECRET-KEY-' "$work/secrets.d/age-keys.txt"; then
  echo 'sops-nix persisted the vault key' >&2; exit 1
fi
echo 'sops-nix: command retrieval, private secret file and no persisted age key passed.'

# The login service must coexist with an agent spawned before the first switch.
(
  export HOME="$work/home" XDG_CONFIG_HOME="$work/agent-config"
  export XDG_DATA_HOME="$work/agent-data" XDG_CACHE_HOME="$work/agent-cache"
  export XDG_RUNTIME_DIR="$work/agent-runtime"
  mkdir -p "$XDG_CONFIG_HOME/rbw" "$XDG_RUNTIME_DIR"
  printf '{"email":"fixture@example.invalid","sync_interval":0}\n' >"$XDG_CONFIG_HOME/rbw/config.json"
  trap 'if [[ -f "$XDG_RUNTIME_DIR/rbw/pidfile" ]]; then kill "$(<"$XDG_RUNTIME_DIR/rbw/pidfile")" 2>/dev/null || true; fi' EXIT
  rbw-agent
  pid=$(<"$XDG_RUNTIME_DIR/rbw/pidfile")
  for _ in {1..100}; do
    [[ -S "$XDG_RUNTIME_DIR/rbw/ssh-agent-socket" ]] && break
    sleep 0.1
  done
  test -S "$XDG_RUNTIME_DIR/rbw/ssh-agent-socket"
  rbw-agent
  test "$(<"$XDG_RUNTIME_DIR/rbw/pidfile")" = "$pid"
)
echo 'rbw-agent: SSH socket and reuse of an existing daemon passed.'
