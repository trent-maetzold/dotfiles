# Warnings for persistence dirs wanting snapshots on a host without volumes.
{lib}: persistence: let
  makeSnapshotted = import ./make-snapshotted.nix {inherit lib;};
  snapshotted = lib.attrNames (makeSnapshotted persistence.dirs);
in
  lib.optional (persistence.volumes == "none" && snapshotted != []) "persistence: ${lib.concatStringsSep ", " snapshotted} want snapshots, but persistence.volumes is none."
