# muninn's 2 GiB ESP and LUKS2-encrypted Btrfs persistent storage.
{inputs, ...}: {
  imports = [inputs.disko.nixosModules.disko];

  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
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
              name = "muninn";
              settings.allowDiscards = true;
              content = {
                type = "btrfs";
                extraArgs = ["-f" "-L" "NIXOS"];
                subvolumes = {
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                };
              };
            };
          };
        };
      };
    };

    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = ["size=8G" "mode=755"];
    };
  };

  fileSystems."/persist".neededForBoot = true;
}
