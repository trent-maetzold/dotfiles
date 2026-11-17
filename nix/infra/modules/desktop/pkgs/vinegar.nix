# Vinegar from main: its WebView2 runs through ANGLE, which fixes the black
# login box (vinegarhq/vinegar#965). Drop once a release after 1.9.4 lands.
{
  flake.overlays.vinegar = final: prev: {
    vinegar = prev.vinegar.overrideAttrs {
      version = "1.9.4-unstable-2026-09-27";
      src = final.fetchFromGitHub {
        owner = "vinegarhq";
        repo = "vinegar";
        rev = "b76ae5af1e5e8bde2052ea8bce17961c622dd4fb";
        hash = "sha256-NZRfP4KX58Qd1eMLn9c5SCEQDwBlhmvUJkAuYxn51eg=";
      };
    };
  };
}
