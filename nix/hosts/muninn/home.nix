# trent's Home Manager config on muninn: every dotfiles home module, plus
# muninn's Niri keybindings and display scaling.
{self, pkgs, ...}: {
  imports = [self.homeModules.default];

  home = {
    username = "trent";
    homeDirectory = "/home/trent";
    stateVersion = "26.11";
    packages = [pkgs.wl-clipboard];
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
    prefer-no-csd
    binds {
      Mod+Space { spawn "noctalia" "msg" "panel-toggle" "launcher"; }
      Mod+H { focus-column-left; }
      Mod+J { focus-workspace-down; }
      Mod+K allow-inhibiting=false { show-hotkey-overlay; }
      Mod+L { focus-column-right; }
      Mod+Shift+H { move-column-left; }
      Mod+Shift+J { move-window-to-workspace-down; }
      Mod+Shift+K { move-window-to-workspace-up; }
      Mod+Shift+L { move-column-right; }
      Mod+Ctrl+J { focus-window-down; }
      Mod+Ctrl+K { focus-window-up; }
      Mod+Ctrl+Shift+J { move-window-down; }
      Mod+Ctrl+Shift+K { move-window-up; }
      Mod+Ctrl+H { focus-column-first; }
      Mod+Ctrl+L { focus-column-last; }
      Mod+Ctrl+Shift+H { move-column-to-first; }
      Mod+Ctrl+Shift+L { move-column-to-last; }
      Mod+Tab { focus-window-previous; }
      Mod+Ctrl+Tab { focus-workspace-previous; }
      Mod+Alt+H { focus-monitor-left; }
      Mod+Alt+J { focus-monitor-down; }
      Mod+Alt+K { focus-monitor-up; }
      Mod+Alt+L { focus-monitor-right; }
      Mod+Alt+Shift+H { move-window-to-monitor-left; }
      Mod+Alt+Shift+J { move-window-to-monitor-down; }
      Mod+Alt+Shift+K { move-window-to-monitor-up; }
      Mod+Alt+Shift+L { move-window-to-monitor-right; }
      Mod+Ctrl+Alt+H { move-column-to-monitor-left; }
      Mod+Ctrl+Alt+J { move-column-to-monitor-down; }
      Mod+Ctrl+Alt+K { move-column-to-monitor-up; }
      Mod+Ctrl+Alt+L { move-column-to-monitor-right; }
      Mod+Ctrl+Alt+Shift+H { move-workspace-to-monitor-left; }
      Mod+Ctrl+Alt+Shift+J { move-workspace-to-monitor-down; }
      Mod+Ctrl+Alt+Shift+K { move-workspace-to-monitor-up; }
      Mod+Ctrl+Alt+Shift+L { move-workspace-to-monitor-right; }
      Mod+Ctrl+Page_Up { move-workspace-up; }
      Mod+Ctrl+Page_Down { move-workspace-down; }
      Mod+Ctrl+Shift+Page_Up { move-column-to-workspace-up; }
      Mod+Ctrl+Shift+Page_Down { move-column-to-workspace-down; }
      Mod+Shift+Page_Up { move-window-to-workspace-up; }
      Mod+Shift+Page_Down { move-window-to-workspace-down; }
      Mod+BracketLeft { consume-or-expel-window-left; }
      Mod+BracketRight { consume-or-expel-window-right; }
      Mod+R { switch-preset-column-width; }
      Mod+Shift+R { switch-preset-window-height; }
      Mod+Ctrl+R { reset-window-height; }
      Mod+Alt+R { switch-preset-column-width-back; }
      Mod+Alt+Shift+R { switch-preset-window-height-back; }
      Mod+Ctrl+Shift+R { switch-preset-window-width; }
      Mod+Ctrl+Alt+R { expand-column-to-available-width; }
      Mod+C { center-column; }
      Mod+Shift+C { center-window; }
      Mod+Ctrl+C { center-visible-columns; }
      Mod+Minus { set-column-width "-10%"; }
      Mod+Equal { set-column-width "+10%"; }
      Mod+Shift+Minus { set-window-height "-10%"; }
      Mod+Shift+Equal { set-window-height "+10%"; }
      Mod+Ctrl+Minus { set-window-width "-10%"; }
      Mod+Ctrl+Equal { set-window-width "+10%"; }
      Mod+V { toggle-window-floating; }
      Mod+Shift+V { switch-focus-between-floating-and-tiling; }
      Mod+Ctrl+V { focus-floating; }
      Mod+Ctrl+Shift+V { focus-tiling; }
      Mod+Alt+V { move-window-to-floating; }
      Mod+Alt+Shift+V { move-window-to-tiling; }
      Mod+Alt+O { toggle-window-rule-opacity; }
      Mod+W { toggle-column-tabbed-display; }
      Mod+O repeat=false { toggle-overview; }
      Mod+Shift+Slash { show-hotkey-overlay; }
      Print { screenshot; }
      Ctrl+Print { screenshot-screen; }
      Alt+Print { screenshot-window; }
      Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }
      Mod+5 { focus-workspace 5; }
      Mod+6 { focus-workspace 6; }
      Mod+7 { focus-workspace 7; }
      Mod+8 { focus-workspace 8; }
      Mod+9 { focus-workspace 9; }
      Mod+Shift+1 { move-window-to-workspace 1; }
      Mod+Shift+2 { move-window-to-workspace 2; }
      Mod+Shift+3 { move-window-to-workspace 3; }
      Mod+Shift+4 { move-window-to-workspace 4; }
      Mod+Shift+5 { move-window-to-workspace 5; }
      Mod+Shift+6 { move-window-to-workspace 6; }
      Mod+Shift+7 { move-window-to-workspace 7; }
      Mod+Shift+8 { move-window-to-workspace 8; }
      Mod+Shift+9 { move-window-to-workspace 9; }
      Mod+Return { spawn "foot"; }
      Mod+grave repeat=false { spawn "dropkitty" "toggle"; }
      Mod+D { spawn "noctalia" "msg" "panel-toggle" "launcher"; }
      Mod+A { spawn "noctalia" "msg" "panel-toggle" "control-center" "audio"; }
      Mod+Shift+A { spawn "noctalia" "msg" "panel-toggle" "control-center"; }
      Mod+B { spawn "noctalia" "msg" "bar-toggle"; }
      Mod+Shift+B { spawn "noctalia" "msg" "bluetooth-toggle"; }
      Mod+Ctrl+B { spawn "noctalia" "msg" "wifi-toggle"; }
      Mod+E { spawn "noctalia" "msg" "settings-toggle"; }
      Mod+I { spawn "noctalia" "msg" "panel-toggle" "control-center" "monitor"; }
      Mod+Ctrl+Space { spawn "noctalia" "msg" "keyboard-layout-cycle"; }
      Mod+N { spawn "noctalia" "msg" "panel-toggle" "control-center" "notifications"; }
      Mod+Shift+N { spawn "noctalia" "msg" "notification-dnd-toggle"; }
      Mod+Alt+N { spawn "noctalia" "msg" "notification-clear-active"; }
      Mod+Ctrl+N { spawn "noctalia" "msg" "notification-invoke-latest"; }
      Mod+P { spawn "noctalia" "msg" "panel-toggle" "clipboard"; }
      Mod+Shift+P { spawn "noctalia" "msg" "panel-toggle" "session"; }
      Mod+Ctrl+P { spawn "noctalia" "msg" "panel-toggle" "launcher" "/emo"; }
      Mod+Ctrl+Escape allow-inhibiting=false { spawn "noctalia" "msg" "session" "lock"; }
      Mod+Pause { spawn "noctalia" "msg" "caffeine-toggle"; }
      Mod+Shift+Pause { spawn "noctalia" "msg" "nightlight-toggle"; }
      Mod+Ctrl+Pause { spawn "noctalia" "msg" "osd-toggle"; }
      Mod+Shift+D { spawn "noctalia" "msg" "dock-toggle"; }
      Mod+Ctrl+D { spawn "noctalia" "msg" "desktop-widgets-toggle"; }
      Mod+Ctrl+Shift+D { spawn "noctalia" "msg" "desktop-widgets-toggle-edit"; }
      Mod+Alt+D { spawn "noctalia" "msg" "theme-mode-toggle"; }
      Mod+Alt+Minus { spawn "noctalia" "msg" "volume-down"; }
      Mod+Alt+Equal { spawn "noctalia" "msg" "volume-up"; }
      Mod+Alt+M { spawn "noctalia" "msg" "volume-mute"; }
      Mod+Ctrl+Alt+M { spawn "noctalia" "msg" "mic-mute"; }
      Mod+Alt+Shift+Minus { spawn "noctalia" "msg" "mic-volume-down"; }
      Mod+Alt+Shift+Equal { spawn "noctalia" "msg" "mic-volume-up"; }
      Mod+Alt+Comma { spawn "noctalia" "msg" "brightness-down"; }
      Mod+Alt+Period { spawn "noctalia" "msg" "brightness-up"; }
      Mod+Alt+P { spawn "noctalia" "msg" "media" "toggle"; }
      Mod+Alt+BracketLeft { spawn "noctalia" "msg" "media" "previous"; }
      Mod+Alt+BracketRight { spawn "noctalia" "msg" "media" "next"; }
      Mod+Ctrl+Alt+BracketLeft { spawn "noctalia" "msg" "wallpaper-previous"; }
      Mod+Ctrl+Alt+BracketRight { spawn "noctalia" "msg" "wallpaper-next"; }
      Mod+Alt+Shift+P { spawn "noctalia" "msg" "power-cycle"; }
      XF86AudioRaiseVolume allow-when-locked=true { spawn "noctalia" "msg" "volume-up"; }
      XF86AudioLowerVolume allow-when-locked=true { spawn "noctalia" "msg" "volume-down"; }
      XF86AudioMute allow-when-locked=true { spawn "noctalia" "msg" "volume-mute"; }
      XF86AudioMicMute allow-when-locked=true { spawn "noctalia" "msg" "mic-mute"; }
      XF86MonBrightnessUp allow-when-locked=true { spawn "noctalia" "msg" "brightness-up"; }
      XF86MonBrightnessDown allow-when-locked=true { spawn "noctalia" "msg" "brightness-down"; }
      XF86KbdBrightnessUp allow-when-locked=true { spawn "noctalia" "msg" "keyboard-backlight-up"; }
      XF86KbdBrightnessDown allow-when-locked=true { spawn "noctalia" "msg" "keyboard-backlight-down"; }
      XF86AudioPlay allow-when-locked=true { spawn "noctalia" "msg" "media" "toggle"; }
      XF86AudioPause allow-when-locked=true { spawn "noctalia" "msg" "media" "pause"; }
      XF86AudioNext allow-when-locked=true { spawn "noctalia" "msg" "media" "next"; }
      XF86AudioPrev allow-when-locked=true { spawn "noctalia" "msg" "media" "previous"; }
      XF86AudioStop allow-when-locked=true { spawn "noctalia" "msg" "media" "stop"; }
      Shift+Print { spawn "noctalia" "msg" "annotate"; }
      Mod+Ctrl+Alt+S { set-dynamic-cast-window; }
      Mod+Ctrl+Alt+Shift+S { set-dynamic-cast-monitor; }
      Mod+Ctrl+Alt+Escape { clear-dynamic-cast-target; }
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
      Mod+Ctrl+F { toggle-windowed-fullscreen; }
      Mod+Alt+F { maximize-window-to-edges; }
      Mod+Shift+E { quit; }
    }
  '';
}
