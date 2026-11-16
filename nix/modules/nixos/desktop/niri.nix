# Niri session, Noctalia greeter and Noctalia shell.
{pkgs, ...}: {
  programs.niri.enable = true;
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    recommendedServices.enable = true;
  };
  # greetd runs the Noctalia greeter; its state (last user, synced
  # appearance) is preserved across the tmpfs root.
  services.displayManager.noctalia-greeter.enable = true;
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
  # Foot comes from Home Manager; Noctalia's launcher replaces fuzzel.
  environment.systemPackages = [pkgs.xwayland-satellite];
}
