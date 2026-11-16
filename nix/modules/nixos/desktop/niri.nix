# Niri session, terminal greeter and Noctalia shell.
{pkgs, ...}: {
  programs.niri.enable = true;
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    recommendedServices.enable = true;
  };
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
      user = "greeter";
    };
  };
  # Keyring for apps' saved logins (gh, ...), unlocked at login.
  services.gnome.gnome-keyring.enable = true;
  # Foot comes from Home Manager; Noctalia's launcher replaces fuzzel.
  environment.systemPackages = [pkgs.xwayland-satellite];
}
