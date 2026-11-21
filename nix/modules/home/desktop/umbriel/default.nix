# The NixOS module supplies the session; Home Manager writes host settings.
{umbriel, ...}: {
  imports = [umbriel.homeModules.default];

  programs.umbriel.enable = true;
}
