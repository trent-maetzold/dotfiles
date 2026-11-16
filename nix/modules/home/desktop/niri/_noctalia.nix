# Noctalia on Niri, from docs.noctalia.dev (compositor-settings/niri): its IPC
# binds, its settings window floating, and window activation from its
# notifications. Super+Alt+L replaces the defaults' swaylock. Each bind has
# a title for the hotkey overlay (Mod+Shift+/). Noctalia itself starts from
# its systemd unit (NixOS).
#
# Noctalia's idle behaviour: screen off at 5 min, lock at 10, suspend at 15
# on battery only (never while plugged in). Lock before any suspend, lid
# included. Noctalia reads every *.toml here; its Settings UI can override.
{pkgs, ...}: let
  noctalia = title: args: {
    _props.hotkey-overlay-title = title;
    spawn = ["noctalia" "msg"] ++ args;
  };
  locked = title: args:
    noctalia title args
    // {
      _props = {
        hotkey-overlay-title = title;
        allow-when-locked = true;
      };
    };
  suspendOnBattery = pkgs.writeShellScript "suspend-on-battery" ''
    ${pkgs.systemd}/bin/systemd-ac-power || exec ${pkgs.systemd}/bin/systemctl suspend
  '';
in {
  wayland.windowManager.niri.settings = {
    binds = {
      "Mod+Space" = noctalia "Launcher" ["panel-toggle" "launcher"];
      "Mod+S" = noctalia "Control center" ["panel-toggle" "control-center"];
      "Mod+Shift+Comma" = noctalia "Noctalia settings" ["settings-toggle"];
      "Super+Alt+L" = noctalia "Lock screen" ["session" "lock"];
      "Alt+Tab" = noctalia "Switch windows" ["window-switcher" "hold"];
      "Alt+Shift+Tab" = noctalia "Switch windows (reverse)" ["window-switcher" "hold" "reverse"];

      # Menus on Mod+Ctrl (Omarchy's letters where they fit; R, F and C stay
      # Niri's window sizing).
      "Mod+Ctrl+A" = noctalia "Audio" ["panel-toggle" "control-center" "audio"];
      "Mod+Ctrl+B" = noctalia "Bluetooth" ["panel-toggle" "control-center" "bluetooth"];
      "Mod+Ctrl+N" = noctalia "Network" ["panel-toggle" "control-center" "network"];
      "Mod+Ctrl+M" = noctalia "Media" ["panel-toggle" "control-center" "media"];
      "Mod+Ctrl+P" = noctalia "Power" ["panel-toggle" "control-center" "power"];
      "Mod+Ctrl+S" = noctalia "System" ["panel-toggle" "control-center" "system"];
      "Mod+Ctrl+D" = noctalia "Calendar" ["panel-toggle" "control-center" "calendar"];
      "Mod+Ctrl+Comma" = noctalia "Notifications" ["panel-toggle" "control-center" "notifications"];
      "Mod+Ctrl+V" = noctalia "Clipboard history" ["panel-toggle" "clipboard"];
      "Mod+Ctrl+E" = noctalia "Emoji" ["panel-toggle" "launcher" "/emo"];
      "Mod+Ctrl+W" = noctalia "Wallpaper" ["panel-toggle" "wallpaper"];

      # Noctalia instead of Niri's own screens: screenshots and the
      # session menu (Niri's quit dialog).
      "Print" = noctalia "Screenshot region" ["screenshot-region"];
      "Ctrl+Print" = noctalia "Screenshot screen" ["screenshot-fullscreen"];
      "Alt+Print" = noctalia "Screenshot window" ["screenshot-window"];
      "Mod+Shift+E" = noctalia "Session menu" ["panel-toggle" "session"];
      "Ctrl+Alt+Delete" = noctalia "Session menu" ["panel-toggle" "session"];

      # Hardware keys; all work on the lock screen.
      "XF86AudioRaiseVolume" = locked "Volume up" ["volume-up"];
      "XF86AudioLowerVolume" = locked "Volume down" ["volume-down"];
      "XF86AudioMute" = locked "Mute" ["volume-mute"];
      "XF86AudioMicMute" = locked "Mute microphone" ["mic-mute"];
      "XF86AudioPlay" = locked "Play/pause" ["media" "toggle"];
      "XF86AudioPause" = locked "Pause" ["media" "pause"];
      "XF86AudioStop" = locked "Stop" ["media" "stop"];
      "XF86AudioNext" = locked "Next track" ["media" "next"];
      "XF86AudioPrev" = locked "Previous track" ["media" "previous"];
      "XF86MonBrightnessUp" = locked "Brightness up" ["brightness-up"];
      "XF86MonBrightnessDown" = locked "Brightness down" ["brightness-down"];
      "XF86KbdBrightnessUp" = locked "Keyboard backlight up" ["keyboard-backlight-up"];
      "XF86KbdBrightnessDown" = locked "Keyboard backlight down" ["keyboard-backlight-down"];
      "XF86KbdLightOnOff" = locked "Keyboard backlight" ["keyboard-backlight-toggle"];
      "XF86Bluetooth" = locked "Bluetooth on/off" ["bluetooth-toggle"];
      "XF86WLAN" = locked "Wi-Fi on/off" ["wifi-toggle"];
      "XF86Search" = noctalia "Launcher" ["panel-toggle" "launcher"];
      "XF86Calculator" = noctalia "Calculator" ["panel-toggle" "launcher" "/calc"];
    };
    _children = [
      {
        window-rule._children = [
          {match._props.app-id = "dev.noctalia.Noctalia";}
          {open-floating = true;}
          {default-column-width.fixed = 1080;}
          {default-window-height.fixed = 920;}
        ];
      }
    ];
    debug.honor-xdg-activation-with-invalid-serial = {};
  };

  xdg.configFile."noctalia/idle.toml".text = ''
    [idle]
    behavior_order = ["screen-off", "lock", "suspend-on-battery"]

    [idle.behavior.screen-off]
    timeout = 300
    action = "screen_off"

    [idle.behavior.lock]
    timeout = 600
    action = "lock"

    [idle.behavior.suspend-on-battery]
    timeout = 900
    action = "command"
    command = "${suspendOnBattery}"

    [lockscreen]
    lock_before_suspend = true
  '';
  # Copy wallpaper and colours to the login greeter when they change. The
  # copy needs admin approval, so Noctalia's own polkit agent asks for it.
  xdg.configFile."noctalia/greeter.toml".text = ''
    [shell]
    polkit_agent = true

    [shell.greeter_sync]
    auto_sync = true
  '';
}
