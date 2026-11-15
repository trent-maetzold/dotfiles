# Niri's input settings and keybindings, on hosts whose NixOS config runs Niri.
# Hosts add their own outputs to the same config.kdl.
{
  lib,
  osConfig ? {},
  ...
}: {
  config = lib.mkIf (osConfig.programs.niri.enable or false) {
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
          // Ignore the touchpad briefly after a key press (palms while typing).
          dwt
        }
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
  };
}
