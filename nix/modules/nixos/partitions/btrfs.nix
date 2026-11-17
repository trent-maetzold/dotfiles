# Unencrypted 4G ESP and Btrfs subvolumes; the host supplies disk.main.device.
{disko, ...}: let
  mountOptions = ["compress=zstd" "noatime"];
in {
  imports = [disko.nixosModules.disko];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  disko.devices.disk.main = {
    type = "disk";

    content = {
      type = "gpt";

      partitions = {
        esp = {
          size = "4G";
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
            type = "btrfs";
            extraArgs = ["-f"];

            subvolumes = {
              "@nix" = {
                mountpoint = "/nix";
                inherit mountOptions;
              };

              "@persist" = {
                mountpoint = "/persist";
                inherit mountOptions;
              };

              "@home" = {
                mountpoint = "/home";
                inherit mountOptions;
              };
            };
          };
        };
      };
    };
  };
}
