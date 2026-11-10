# Resolve .env.secrets references from the vault CLIs on PATH (ksm, keeper,
# rbw, sops, age) into shell exports; see secrets-env.sh and mkSecretsShell.
{
  writeShellApplication,
  jq,
}:
writeShellApplication {
  name = "secrets-env";
  runtimeInputs = [jq];
  text = builtins.readFile ./secrets-env.sh;
}
