{
  boot = {
    # The OCI image's layout: GRUB as the removable EFI loader on /boot. The
    # 249M ESP holds kernel copies for two systems at most, during a switch.
    loader.grub = {
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
      configurationLimit = 1;
    };

    growPartition = true;
    kernelParams = ["net.ifnames=0"];
  };
}
