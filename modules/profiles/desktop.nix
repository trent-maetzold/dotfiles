{config, ...}: {
  flake.modules.homeManager.desktopProfile = {
    imports = with config.flake.modules.homeManager; [
      desktop-btop
      clipboard
      cursor
      ghostty
      luakit
      desktop-magpie
      desktop-tuios
      zen
      umbriel
      umbriel-idle
    ];
  };
}
