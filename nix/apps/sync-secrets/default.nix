{
  pkgs,
  app,
}:
app "Refresh sops secrets from Keeper/rbw (secrets.sources)" (pkgs.writeShellApplication {
  name = "sync-secrets";
  runtimeInputs = with pkgs; [uv secrets-env keeper-commander keeper-secrets-manager-cli rbw sops git];
  text = ''exec uv run --quiet --script ${./.}/sync-secrets "$@"'';
})
