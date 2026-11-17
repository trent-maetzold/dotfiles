# Database TUIs: harlequin (SQL), tredis (Redis).
{config, ...}: let
  modules.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [harlequin tredis];
  };
in {
  # Flake Modules
  flake.modules.homeManager.pkgs-data = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.pkgs-data];
}
