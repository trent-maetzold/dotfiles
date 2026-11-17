{
  # Headless: a failed unit must not isolate into a locked emergency shell.
  systemd.enableEmergencyMode = false;

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.efiSysMountPoint = "/boot/efi";
    };

    zfs.forceImportRoot = true;
  };
}
