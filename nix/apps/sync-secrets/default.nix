{
  pkgs,
  app,
}:
# shortcut: libraries repeat the script's PEP 723 dependencies; keep them in sync.
app "Refresh sops secrets from Keeper/rbw (secrets.sources)" (pkgs.writers.writePython3Bin "sync-secrets" {
  libraries = ps: with ps; [typer pydantic-settings python-dotenv gitpython];
  flakeIgnore = ["E501"];
  makeWrapperArgs = ["--prefix" "PATH" ":" (pkgs.lib.makeBinPath (with pkgs; [secrets-env keeper-commander keeper-secrets-manager-cli rbw sops git]))];
} (builtins.readFile ./sync-secrets.py))
