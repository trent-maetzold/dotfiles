# Disk `main`: a 4G ESP with systemd-boot and btrfs @nix, @persist and @home.
# Hosts set `disko.devices.disk.main.device`.
{config, ...}: {
  # Flake Modules
  flake.modules.nixos.disko-btrfs = import ../../../../modules/nixos/partitions/btrfs.nix;

  # NixOS Configuration Modules
  flake.nixosModules.frigg.imports = [config.flake.modules.nixos.disko-btrfs];
  flake.nixosModules.thor.imports = [config.flake.modules.nixos.disko-btrfs];
}
