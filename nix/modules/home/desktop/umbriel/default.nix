# Keep the packaged keybinds and defaults when layering host settings on top.
{umbriel, osConfig, ...}: {
  imports = [umbriel.homeModules.default];

  programs.umbriel = {
    enable = true;
    settings.include.files = ["${osConfig.programs.umbriel.package}/share/umbriel/config.toml"];
  };
}
