# Wayland clipboard command-line utilities, independent of the compositor.
{pkgs, ...}: {
  home.packages = [pkgs.wl-clipboard];
}
