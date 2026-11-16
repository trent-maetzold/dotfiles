# Luakit: blank start pages, fonts, no decorations.
{pkgs, ...}: {
  home.packages = [pkgs.luakit];
  xdg.configFile."luakit/userconf.lua".source = ./userconf.lua;
}
