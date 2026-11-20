# Umbriel: its packaged configuration, configured at runtime for now. The
# compositor and session come from the NixOS module
# (nix/modules/nixos/desktop/umbriel); this leaves the Home Manager module in
# place for the config that moves here once it is dialled in.
{umbriel, ...}: {
  imports = [umbriel.homeModules.default];

  programs.umbriel.enable = true;
}
