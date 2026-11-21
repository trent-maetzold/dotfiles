# The NixOS module supplies the session; Home Manager writes host settings.
{config, umbriel, ...}: {
  imports = [umbriel.homeModules.default];

  programs.umbriel = {
    enable = true;
    settings = {
      include.files = ["/etc/xdg/umbriel/config.toml"];
      input.cursor = {
        theme = config.home.pointerCursor.name;
        size = config.home.pointerCursor.size;
      };
    };
  };
}
