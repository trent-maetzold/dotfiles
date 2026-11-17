# Rust via rustup, with lldb.
{config, ...}: let
  modules.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [lldb rustup];
    programs.lazyvim.extras.lang.rust.enable = true;
  };
in {
  # Flake Modules
  flake.modules.homeManager.lang-rust = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.lang-rust];
}
