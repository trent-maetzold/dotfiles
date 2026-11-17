{
  disko,
  disko-zfs,
  ...
}: let
  makeDisk = {
    n,
    serial,
  }: {
    imports = [
      (import ../../../../modules/nixos/partitions/esp-zfs.nix {
        name = "nvme${toString n}";
        pool = "tank";
        espLabel = "esp${toString n}";
        espMountpoint =
          if n == 0
          then "/boot/efi"
          else null;
      })
    ];
    disko.devices.disk."nvme${toString n}".device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_2TB_${serial}";
  };
in {
  imports = [
    disko.nixosModules.disko
    disko-zfs.nixosModules.default
    (makeDisk {
      n = 0;
      serial = "S59CNM0W619880X";
    })
    (makeDisk {
      n = 1;
      serial = "S59CNM0W538791D";
    })
    (makeDisk {
      n = 2;
      serial = "S59CNM0W518854F";
    })
    (makeDisk {
      n = 3;
      serial = "S59CNM0W518856Z";
    })
    (makeDisk {
      n = 4;
      serial = "S59CNM0W619589N";
    })
    (makeDisk {
      n = 5;
      serial = "S59CNM0W619882P";
    })
    (makeDisk {
      n = 6;
      serial = "S59CNM0W619751J";
    })
  ];

  disko = {
    zfs.enable = true;
    devices.zpool.tank = {
      type = "zpool";
      mode = "raidz2";
      options = {
        ashift = "12";
        autoexpand = "on";
      };
      rootFsOptions = {
        compression = "zstd";
        xattr = "sa";
        acltype = "posixacl";
        recordsize = "1M";
        mountpoint = "none";
      };
      datasets = {
        root = {
          type = "zfs_fs";
          mountpoint = "/";
          options.mountpoint = "legacy";
        };
        boot = {
          type = "zfs_fs";
          mountpoint = "/boot";
          options.mountpoint = "legacy";
        };
      };
    };
  };
}
