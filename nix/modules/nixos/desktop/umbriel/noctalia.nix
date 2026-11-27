# Noctalia shell and its greeter. greetd runs the greeter; its state (last
# user, synced appearance) is preserved across the tmpfs root.
{pkgs, ...}: {
  # No settings on purpose: Noctalia always loads its built-in defaults, then
  # GUI changes from ~/.local/state/noctalia/settings.toml.
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    recommendedServices.enable = true;
  };
  services.displayManager.noctalia-greeter = {
    enable = true;
    # The greeter runs as `greeter`, so it never sees the desktop's Home Manager
    # cursor; without this it falls back to Adwaita's black arrows.
    cursorTheme = {
      package = pkgs.vanilla-dmz;
      name = "DMZ-White";
    };
    settings = {
      # Global UI scale; per-output `scales` did not take effect here.
      output.scale = 1.5;
      cursor.size = 24;
    };
  };
  preservation.preserveAt."/persist".directories = [
    {
      directory = "/var/lib/noctalia-greeter";
      user = "greeter";
      group = "greeter";
      mode = "0750";
    }
  ];
}
