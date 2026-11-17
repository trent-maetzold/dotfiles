# QEMU guest drivers.
{config, ...}: let
  modules.nixos = {modulesPath, ...}: {
    imports = ["${modulesPath}/profiles/qemu-guest.nix"];
  };
in {
  # Flake Modules
  flake.modules.nixos.qemu-guest = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.heimdall.imports = [config.flake.modules.nixos.qemu-guest];
}
