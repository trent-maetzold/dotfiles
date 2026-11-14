if ! rbw unlocked; then
  echo 'Unlock Bitwarden with rbw unlock before switching generations.' >&2
  exit 1
fi

# Use only the vault key, not a leftover identity in the caller's environment.
unset SOPS_AGE_KEY SOPS_AGE_SSH_PRIVATE_KEY_FILE SOPS_AGE_SSH_PRIVATE_KEY_CMD
export SOPS_AGE_KEY_FILE=/dev/null
export SOPS_AGE_KEY_CMD='rbw get age-master'
sops --decrypt "$1" >/dev/null
