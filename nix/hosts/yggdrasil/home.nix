{
  lib,
  self,
  user,
  ...
}: {
  imports = [self.homeModules.default];

  home = {
    username = user.name;
    homeDirectory = user.home;
    stateVersion = "26.11";
  };

  # Yggdrasil already runs these daemons as system services.
  systemd.user.services.paseo.Install.WantedBy = lib.mkForce [];
  virtualisation.quadlet.containers.magpie.autoStart = lib.mkForce false;
}
