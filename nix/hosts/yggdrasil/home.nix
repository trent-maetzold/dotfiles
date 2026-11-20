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
  systemd.user.services.magpie.Install.WantedBy = lib.mkForce [];
}
