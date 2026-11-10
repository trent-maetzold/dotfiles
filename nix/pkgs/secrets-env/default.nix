# Resolve .env.secrets references into shell exports; see secrets-env.py.
# runtimeInputs put the vault CLIs on PATH; uv runs the script itself.
{
  writeShellApplication,
  uv,
  keeper-commander,
  keeper-secrets-manager-cli,
  rbw,
  sops,
  age,
}:
writeShellApplication {
  name = "secrets-env";
  runtimeInputs = [uv keeper-commander keeper-secrets-manager-cli rbw sops age];
  text = ''exec ${./secrets-env.py} "$@"'';
}
