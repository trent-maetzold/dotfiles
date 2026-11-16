# Niri session, Noctalia greeter and Noctalia shell.
{
  config,
  pkgs,
  ...
}: {
  programs.niri.enable = true;
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    recommendedServices.enable = true;
  };
  services.greetd = {
    enable = true;
    settings.default_session = {
      # The greeter lists sessions from XDG_DATA_DIRS/wayland-sessions.
      command = "env XDG_DATA_DIRS=${config.services.displayManager.sessionData.desktops}/share ${pkgs.noctalia-greeter}/bin/noctalia-greeter-session";
      user = "greeter";
    };
  };
  # Greeter state: remembered user/session, synced appearance.
  systemd.tmpfiles.packages = [pkgs.noctalia-greeter];
  preservation.preserveAt."/persist".directories = [
    {
      directory = "/var/lib/noctalia-greeter";
      user = "greeter";
      group = "greeter";
      mode = "0750";
    }
  ];
  # Keyring for apps' saved logins (gh, ...), unlocked at login.
  services.gnome.gnome-keyring.enable = true;
  # Foot comes from Home Manager; Noctalia's launcher replaces fuzzel. The
  # greeter package gives Noctalia its sync helper and polkit action.
  environment.systemPackages = [pkgs.xwayland-satellite pkgs.noctalia-greeter];
}
