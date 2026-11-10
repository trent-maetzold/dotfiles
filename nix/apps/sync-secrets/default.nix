# Needs uv, plus the CLIs for your sources (keeper, ksm, rbw), sops, git and
# secrets-env on PATH.
{app, ...}: app "Refresh sops secrets from Keeper/rbw (secrets.sources)" ./sync-secrets.py
