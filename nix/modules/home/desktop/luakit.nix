# Luakit, on graphical desktops: blank start pages, fonts, no decorations.
{
  lib,
  osConfig ? {},
  pkgs,
  ...
}: {
  config = lib.mkIf (osConfig.services.graphical-desktop.enable or false) {
    home.packages = [pkgs.luakit];
    xdg.configFile."luakit/userconf.lua".source = ./luakit/userconf.lua;
  };
}
