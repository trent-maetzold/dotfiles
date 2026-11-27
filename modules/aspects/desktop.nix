{config, ...}: {
  flake.modules.homeManager.desktopProfile = {
    imports = with config.flake.modules.homeManager; [
      clipboard
      cursor
      ghostty
      luakit
      zen
    ];
  };
}
