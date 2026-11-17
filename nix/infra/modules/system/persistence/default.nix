# State that outlives a reboot. Features declare what they need; the host
# picks how: `volumes` for dirs wanting snapshots, `plain` for the rest. On a
# persistent root (`none`) there is nothing to do.
{
  config,
  lib,
  ...
}: let
  makeSnapshotWarnings = import ./_lib/make-snapshot-warnings.nix {inherit lib;};
in let
  modules.nixos = {config, ...}: {warnings = makeSnapshotWarnings config.persistence;};
in {
  # Flake Modules
  flake.modules.nixos.persistence = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.default.imports = [config.flake.modules.nixos.persistence];
}
