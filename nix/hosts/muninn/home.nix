# trent's Home Manager config on muninn: every dotfiles home module, plus
# muninn's Niri keybindings and display scaling.
{self, ...}: {
  imports = [self.homeModules.default];

  home = {
    username = "trent";
    homeDirectory = "/home/trent";
    stateVersion = "26.11";
  };

  xdg.configFile."niri/config.kdl".text = ''
    input {
      keyboard {
        xkb {
          layout "us"
        }
      }
      touchpad {
        tap
        natural-scroll
      }
    }
    output "eDP-1" {
      scale 1.5
    }
    binds {
      Mod+Return { spawn "foot"; }
      Mod+D { spawn "fuzzel"; }
      Mod+Q { close-window; }
      Mod+Left { focus-column-left; }
      Mod+Right { focus-column-right; }
      Mod+Up { focus-window-up; }
      Mod+Down { focus-window-down; }
      Mod+Shift+Left { move-column-left; }
      Mod+Shift+Right { move-column-right; }
      Mod+Shift+Up { move-window-up; }
      Mod+Shift+Down { move-window-down; }
      Mod+Page_Up { focus-workspace-up; }
      Mod+Page_Down { focus-workspace-down; }
      Mod+F { maximize-column; }
      Mod+Shift+F { fullscreen-window; }
      Mod+Shift+E { quit; }
    }
  '';
}
