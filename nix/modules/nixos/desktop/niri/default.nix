# Niri session. The shell and greeter come from _noctalia.nix.
{pkgs, ...}: {
  imports = [./_noctalia.nix];

  programs.niri.enable = true;
  # Keyring for apps' saved logins (gh, ...), unlocked at login.
  services.gnome.gnome-keyring.enable = true;
  # Ghostty comes from Home Manager; Noctalia's launcher replaces fuzzel.
  environment.systemPackages = [pkgs.xwayland-satellite];
}
