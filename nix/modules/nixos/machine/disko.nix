# 2 GiB ESP and LUKS2-encrypted Btrfs persistent storage. / is wiped every
# boot: a tmpfs (machine.root = "tmpfs"), or a Btrfs subvolume that early boot
# replaces with an empty one (machine.root = "btrfs"), keeping the previous
# boot's root as @old-root until the next boot.
# Hosts override disko.devices.disk.main.device or the tmpfs size if needed.
{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.machine;
  luks = config.networking.hostName;
  subvolume = mountpoint: {
    inherit mountpoint;
    mountOptions = ["compress=zstd" "noatime"];
  };
in {
  imports = [inputs.disko.nixosModules.disko];

  options.machine.root = lib.mkOption {
    type = lib.types.enum ["tmpfs" "btrfs"];
    default = "tmpfs";
    description = "Where the wiped-every-boot / lives: RAM, or a Btrfs subvolume on disk.";
  };

  config = lib.mkMerge [
    {
      disko.devices.disk.main = {
        type = "disk";
        device = lib.mkDefault "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["fmask=0077" "dmask=0077"];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "luks";
                name = luks;
                settings.allowDiscards = true;
                content = {
                  type = "btrfs";
                  extraArgs = ["-f" "-L" "NIXOS"];
                  subvolumes =
                    {
                      "@nix" = subvolume "/nix";
                      "@persist" = subvolume "/persist";
                      "@home" = subvolume "/home";
                    }
                    // lib.optionalAttrs (cfg.root == "btrfs") {"@root" = subvolume "/";};
                };
              };
            };
          };
        };
      };

      fileSystems."/persist".neededForBoot = true;
    }

    (lib.mkIf (cfg.root == "tmpfs") {
      disko.devices.nodev."/" = {
        fsType = "tmpfs";
        mountOptions = lib.mkDefault ["size=8G" "mode=755"];
      };
    })

    (lib.mkIf (cfg.root == "btrfs") {
      # After unlocking, before mounting /: keep the last root as @old-root
      # and start this boot from an empty @root.
      boot.initrd.systemd.services.wipe-root = let
        device = "dev-mapper-${luks}.device";
      in {
        description = "Replace the root subvolume with an empty one";
        wantedBy = ["initrd.target"];
        requires = [device];
        after = [device];
        before = ["sysroot.mount"];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          mkdir -p /btrfs-top
          mount -t btrfs -o subvolid=5 /dev/mapper/${luks} /btrfs-top
          if [ -e /btrfs-top/@root ]; then
            if [ -e /btrfs-top/@old-root ]; then
              btrfs subvolume delete --recursive /btrfs-top/@old-root
            fi
            mv /btrfs-top/@root /btrfs-top/@old-root
          fi
          btrfs subvolume create /btrfs-top/@root
          umount /btrfs-top
        '';
      };
    })
  ];
}
