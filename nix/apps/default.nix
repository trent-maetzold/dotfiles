# Flake apps: tasks for administering NixOS/Home Manager deployments, so a host
# flake can re-export them (apps = dotfiles.apps). The justfiles wrap each one.
pkgs: let
  app = description: drv: {
    type = "app";
    program = pkgs.lib.getExe drv;
    meta = {inherit description;};
  };
in {
  sync-secrets = app "Refresh sops secrets from Keeper/rbw (secrets.sources)" (pkgs.writeShellApplication {
    name = "sync-secrets";
    runtimeInputs = with pkgs; [secrets-env keeper-commander keeper-secrets-manager-cli rbw sops jq git];
    text = builtins.readFile ./sync-secrets.sh;
  });

  import-windows-ca = app "Export the Windows CAs (WSL) to a PEM bundle" (pkgs.writeShellApplication {
    name = "import-windows-ca";
    runtimeEnv.PS1_SCRIPT = ./import-windows-ca.ps1;
    text = builtins.readFile ./import-windows-ca.sh;
  });
}
