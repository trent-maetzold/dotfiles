{
  pkgs,
  app,
}:
app "Refresh sops secrets from Keeper/rbw (secrets.sources)" (pkgs.writeShellApplication {
  name = "sync-secrets";
  runtimeInputs = with pkgs; [secrets-env keeper-commander keeper-secrets-manager-cli rbw sops jq git];
  text = builtins.readFile ./sync-secrets.sh;
})
