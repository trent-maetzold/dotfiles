# Resolve .env.secrets references from the vault CLIs on PATH (ksm, keeper,
# rbw, sops, age) into shell exports; see secrets-env.sh and mkSecretsShell.
{writeShellApplication}:
writeShellApplication {
  name = "secrets-env";
  text = builtins.readFile ./secrets-env.sh;
}
