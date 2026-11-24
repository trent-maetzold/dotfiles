{lib, ...}: {
  imports = [../../users/trent];

  # Yggdrasil has no desktop session: it runs the CLI's headless gateway, which
  # agents on other hosts reach over the tailnet/Docker.
  services.magpie.enable = true;

  # Yggdrasil already runs these daemons as system services.
  systemd.user.services.paseo.Install.WantedBy = lib.mkForce [];
  systemd.user.services.magpie.Install.WantedBy = lib.mkForce [];
}
