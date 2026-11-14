# Flatpak with Flathub, and GNOME Software as the app store: users install
# their own apps without touching the NixOS config.
{pkgs, ...}: {
  services.flatpak.enable = true;
  environment.systemPackages = [pkgs.gnome-software];

  systemd.services.flathub = {
    description = "Add the Flathub remote";
    wantedBy = ["multi-user.target"];
    wants = ["network-online.target"];
    after = ["network-online.target"];
    path = [pkgs.flatpak];
    script = "flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo";
    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = 30;
    };
  };

  # System-wide installs live here; per-user ones are under /home.
  preservation.preserveAt."/persist".directories = ["/var/lib/flatpak"];
}
