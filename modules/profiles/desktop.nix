{config, ...}: {
  flake.modules.homeManager.desktopProfile = {
    imports = with config.flake.modules.homeManager; [
      desktop-btop
      desktop-clipboard
      desktop-cursor
      desktop-ghostty
      desktop-luakit
      desktop-magpie
      desktop-tuios
      desktop-zen-default
      umbriel
      umbriel-idle
    ];
  };
}
