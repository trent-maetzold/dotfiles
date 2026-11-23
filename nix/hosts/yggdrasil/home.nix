{lib, ...}: {
  imports = [../../users/trent];

  # Yggdrasil already runs these daemons as system services.
  systemd.user.services.paseo.Install.WantedBy = lib.mkForce [];
  systemd.user.services.magpie.Install.WantedBy = lib.mkForce [];
}
