# Deploy tools: colmena, nixos-anywhere.
{config, ...}: let
  modules.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [colmena nixos-anywhere];
  };
in {
  # Flake Modules
  flake.modules.homeManager.pkgs-infra = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.infra.imports = [config.flake.modules.homeManager.pkgs-infra];
}
