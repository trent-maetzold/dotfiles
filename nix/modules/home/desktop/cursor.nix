# A shared cursor theme for desktop applications.
{pkgs, ...}: {
  home.pointerCursor = {
    enable = true;
    package = pkgs.vanilla-dmz;
    name = "DMZ-White";
    size = 32;
  };
}
