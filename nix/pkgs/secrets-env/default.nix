# Resolve .env.secrets references from the vault CLIs on PATH (ksm, keeper,
# rbw, sops, age) into shell exports; see ./secrets-env. uv installs the
# script's PEP 723 dependencies from secrets-env.lock on first run.
{
  writeShellApplication,
  uv,
}:
writeShellApplication {
  name = "secrets-env";
  runtimeInputs = [uv];
  text = ''exec uv run --quiet --script ${./.}/secrets-env "$@"'';
}
