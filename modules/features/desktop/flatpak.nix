{
  flake.modules.nixos.flatpak =
    # Flatpak with a per-user Flathub remote, and GNOME Software as the app store:
    # users without admin rights install their own apps into ~/.local/share/flatpak
    # (on /home, so they persist). No system-wide remote, so nothing asks for an
    # admin password.
    {pkgs, ...}: {
      services.flatpak.enable = true;
      environment.systemPackages = [pkgs.gnome-software];

      systemd.user.services.flathub = {
        description = "Add the per-user Flathub remote";
        wantedBy = ["default.target"];
        path = [pkgs.flatpak];
        script = "flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo";
        serviceConfig = {
          Type = "oneshot";
          # The first login may come before the network is up.
          Restart = "on-failure";
          RestartSec = 30;
        };
      };
    };
}
