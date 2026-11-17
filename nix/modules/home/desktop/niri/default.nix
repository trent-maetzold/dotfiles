# Niri: its default config (default-config.kdl, binds included), with our
# bindings (binds.nix) and Noctalia's (_noctalia.nix) on top. NixOS's
# programs.niri provides the session, units and portals; this writes and
# validates ~/.config/niri/config.kdl.
{pkgs, ...}: {
  imports = [
    ./binds.nix
    ./_noctalia.nix
  ];

  home.packages = [pkgs.wl-clipboard];

  wayland.windowManager.niri = {
    enable = true;
    enableDefaultConfig = true;
    systemd.enable = false;
    portalPackage = null;
    xwaylandSatellitePackage = null;
    settings = {
      input.touchpad = {
        tap = {};
        natural-scroll = {};
        # Ignore the touchpad briefly after a key press (palms while typing).
        dwt = {};
      };
      prefer-no-csd = {};
    };
  };
}
