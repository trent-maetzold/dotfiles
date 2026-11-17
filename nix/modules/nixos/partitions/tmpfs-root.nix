# Preserve the imported layout: a 2G tmpfs root backed by /persist.
{
  fileSystems."/persist".neededForBoot = true;
  disko.devices.nodev."/" = {
    fsType = "tmpfs";
    mountOptions = ["size=2G" "mode=755"];
  };
}
