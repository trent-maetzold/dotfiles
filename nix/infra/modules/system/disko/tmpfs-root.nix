# `/` is a 2G tmpfs; state lives on /persist.
{config, ...}: {
  # Flake Modules
  flake.modules.nixos.disko-tmpfs-root = import ../../../../modules/nixos/partitions/tmpfs-root.nix;

  # NixOS Configuration Modules
  flake.nixosModules.frigg.imports = [config.flake.modules.nixos.disko-tmpfs-root];
  flake.nixosModules.thor.imports = [config.flake.modules.nixos.disko-tmpfs-root];
}
