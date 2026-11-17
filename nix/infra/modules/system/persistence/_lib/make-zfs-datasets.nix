# A disko-zfs dataset per snapshotted `persistence` dir, named for its last component.
{lib}: dirs: let
  makeSnapshotted = import ./make-snapshotted.nix {inherit lib;};
in
  lib.mapAttrs' (dir: d:
    lib.nameValuePair (baseNameOf dir) {
      type = "zfs_fs";
      mountpoint = dir;
      options = {mountpoint = "legacy";} // d.zfs;
      # A switch can add a dataset; mount it only once disko-zfs created it.
      mountOptions = ["x-systemd.requires=disko-zfs.service"];
    })
  (makeSnapshotted dirs)
