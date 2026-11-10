# runtimeInputs put the CLIs the script calls on PATH; uv runs the script itself.
{
  pkgs,
  app,
}:
app "Refresh sops secrets from Keeper/rbw (secrets.sources)" (pkgs.lib.getExe (pkgs.writeShellApplication {
  name = "sync-secrets";
  runtimeInputs = with pkgs; [uv keeper-commander keeper-secrets-manager-cli rbw sops git];
  text = ''exec ${./sync-secrets.py} "$@"'';
}))
