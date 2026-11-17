# LibreOffice from Flathub.
{config, ...}: let
  modules.homeManager.services.flatpak.packages = ["org.libreoffice.LibreOffice"];
in {
  # Flake Modules
  flake.modules.homeManager.libreoffice = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.justine.imports = [config.flake.modules.homeManager.libreoffice];
}
