# Google Chrome from Flathub.
{config, ...}: let
  modules.homeManager.services.flatpak.packages = ["com.google.Chrome"];
in {
  # Flake Modules
  flake.modules.homeManager.google-chrome = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.justine.imports = [config.flake.modules.homeManager.google-chrome];
}
