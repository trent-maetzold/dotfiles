# rbw, the Bitwarden CLI that holds the age master key.
{config, ...}: let
  modules.homeManager = {
    bitwardenEmail,
    pkgs,
    ...
  }: {
    programs.rbw = {
      enable = true;

      settings = {
        email = bitwardenEmail;
        pinentry = pkgs.pinentry-curses;
      };
    };
  };
in {
  # Flake Modules
  flake.modules.homeManager.rbw = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.infra.imports = [config.flake.modules.homeManager.rbw];
}
