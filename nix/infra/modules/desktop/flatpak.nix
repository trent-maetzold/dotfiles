# Flatpak with Flathub; users with the home part install their own apps,
# declared or from GNOME Software.
{
  config,
  nix-flatpak,
  ...
}: {
  # Flake Modules
  flake.modules = {
    nixos.flatpak = {
      services.flatpak.enable = true;
      persistence.dirs."/var/lib/flatpak" = {};
    };

    homeManager.flatpak = {pkgs, ...}: {
      imports = [nix-flatpak.homeManagerModules.nix-flatpak];

      services.flatpak.enable = true;
      home.packages = [pkgs.gnome-software];
    };
  };

  # NixOS Configuration Modules
  flake.nixosModules.desktop.imports = [config.flake.modules.nixos.flatpak];

  # Home Configuration Modules
  flake.homeModules = {
    justine.imports = [config.flake.modules.homeManager.flatpak];
    trent.imports = [config.flake.modules.homeManager.flatpak];
  };
}
