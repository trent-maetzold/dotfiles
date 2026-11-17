# Python with uv, ruff and ty.
{config, ...}: let
  modules.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [python3 python3Packages.debugpy ruff ty uv];
    programs.lazyvim.extras.lang.python.enable = true;
  };
in {
  # Flake Modules
  flake.modules.homeManager.lang-python = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.lang-python];
}
