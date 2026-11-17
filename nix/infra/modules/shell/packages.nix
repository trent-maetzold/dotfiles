# Everyday CLI basics: curl, wget, gcc, make, just, openssl, tree, unzip.
{config, ...}: let
  packages = pkgs: with pkgs; [curl gcc git gnumake just openssh openssl pkg-config tree unzip wget];
  modules.nixos = {pkgs, ...}: {environment.systemPackages = packages pkgs;};
  modules.homeManager = {pkgs, ...}: {home.packages = packages pkgs;};
in {
  # Flake Modules
  flake.modules.nixos.pkgs-admin = modules.nixos;
  flake.modules.homeManager.pkgs-admin = modules.homeManager;

  # NixOS Configuration Modules
  flake.nixosModules.default.imports = [config.flake.modules.nixos.pkgs-admin];

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.pkgs-admin];
}
