{
  config,
  umbriel,
  ...
}:
{
  flake.modules.homeManager.umbriel = {
    imports = [ umbriel.homeModules.default ];

    programs.umbriel = {
      enable = true;
      settings = {
        include.files = [ "/etc/xdg/umbriel/config.toml" ];
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
          "Mod+Shift+Slash" = "cheatsheet-toggle";
          "Mod+Ctrl+L" = "spawn noctalia msg session lock";
        };
        input.cursor = {
          theme = config.home.pointerCursor.name;
          size = config.home.pointerCursor.size;
        };
        xdg.configFile."noctalia/idle.toml".text = ''
          [lockscreen]
          lock_before_suspend = true

          [idle.behavior.lock]
          enabled = true
          timeout = 600
          action = "lock"

          [idle.behavior.screen-off]
          enabled = true
          timeout = 660
          action = "screen_off"

          [idle.behavior.lock-and-suspend]
          enabled = true
          timeout = 900
          action = "lock_and_suspend"
        '';

      };
    };
  };

  flake.modules.nixos.umbriel = {
    imports = [ umbriel.nixosModules.default ];

    programs.umbriel.enable = true;
    environment.etc."xdg/umbriel/config.toml".source =
      "${config.programs.umbriel.package}/share/umbriel/config.toml";
  };
}
