# Keep ten generations in the boot menu.
{config, ...}: let
  modules.nixos.boot.loader.systemd-boot.configurationLimit = 10;
in {
  # Flake Modules
  flake.modules.nixos.boot = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.default.imports = [config.flake.modules.nixos.boot];
}
