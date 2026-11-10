# Flake apps: tasks for administering NixOS/Home Manager deployments, so a host
# flake can re-export them (apps = dotfiles.apps). The justfiles wrap each one.
pkgs: let
  app = description: drv: {
    type = "app";
    program = pkgs.lib.getExe drv;
    meta = {inherit description;};
  };
in {
  # Log in to Keeper if the saved session expired (keeper-secrets module), then
  # `nh os switch`, whose activation fetches the secrets. Args go to nh.
  switch = app "Log in to Keeper if needed, then nh os switch" (pkgs.writeShellApplication {
    name = "switch";
    runtimeInputs = [pkgs.keeper-secrets pkgs.nh];
    text = ''
      keeper-secrets-login
      exec nh os switch "$@"
    '';
  });

  import-windows-ca = app "Export the Windows CAs (WSL) to a PEM bundle" (pkgs.writeShellApplication {
    name = "import-windows-ca";
    runtimeEnv.PS1_SCRIPT = ./import-windows-ca.ps1;
    text = builtins.readFile ./import-windows-ca.sh;
  });
}
