{
  flake.modules.homeManager.muninn = {
    programs.umbriel.settings = {
      output."eDP-1".scale = 1.4;
      keybinds = {
        "Mod+Return" = {
          action = "spawn ghostty";
          repeat = false;
        };
        "Mod+B" = {
          action = "spawn luakit";
          repeat = false;
        };
        "Mod+Shift+B" = {
          action = "spawn zen-beta";
          repeat = false;
        };
        "Mod+Ctrl+L" = "spawn noctalia msg session lock";
      };
    };
  };
}
