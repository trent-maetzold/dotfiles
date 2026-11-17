# Snapshotted `persistence` dirs get their own dataset on `persistence.zfs.pool`;
# the rest live on the persistent root.
{
  config,
  lib,
  ...
}: let
  makeZfsDatasets = import ./_lib/make-zfs-datasets.nix {inherit lib;};
in let
  modules.nixos = {config, ...}: {
    persistence.volumes = "zfs";
    disko.devices.zpool.${config.persistence.zfs.pool}.datasets = makeZfsDatasets config.persistence.dirs;
  };
in {
  # Flake Modules
  flake.modules.nixos.persistence-zfs = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.yggdrasil.imports = [
    config.flake.modules.nixos.persistence-zfs
    {persistence.zfs.pool = "tank";}
  ];
}
