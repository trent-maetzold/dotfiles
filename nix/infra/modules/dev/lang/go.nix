# Go toolchain, gopls and delve.
{config, ...}: let
  modules.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [delve go gopls gotools];
    programs.lazyvim.extras.lang.go.enable = true;
  };
in {
  # Flake Modules
  flake.modules.homeManager.lang-go = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.lang-go];
}
