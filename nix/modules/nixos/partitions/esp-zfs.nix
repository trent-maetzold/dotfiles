# Partition scheme only; the host supplies the device, pool and topology.
{
  name,
  pool,
  espLabel,
  espMountpoint ? null,
}: {
  disko.devices.disk.${name} = {
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        esp = {
          size = "1G";
          type = "EF00";
          label = espLabel;
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = espMountpoint;
            mountOptions = ["fmask=0077" "dmask=0077"];
          };
        };
        zfs = {
          size = "100%";
          content = {
            type = "zfs";
            inherit pool;
          };
        };
      };
    };
  };
}
