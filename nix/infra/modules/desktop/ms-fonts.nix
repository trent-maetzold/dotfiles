# Microsoft's core and Vista fonts, so Office documents and web pages look right.
{config, ...}: let
  modules.nixos = {pkgs, ...}: {
    fonts.packages = [pkgs.corefonts pkgs.vista-fonts];
    nixpkgs.config.allowUnfreePackages = ["corefonts" "vista-fonts"];
    # Flatpak apps see host fonts through /run/current-system/sw/share/X11/fonts.
    fonts.fontDir.enable = true;
  };
in {
  # Flake Modules
  flake.modules.nixos.ms-fonts = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.desktop.imports = [config.flake.modules.nixos.ms-fonts];
}
