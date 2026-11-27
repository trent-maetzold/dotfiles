{
  flake.modules.homeManager.luakit = {pkgs, ...}: {
    home.packages = [pkgs.luakit];
  };
}
