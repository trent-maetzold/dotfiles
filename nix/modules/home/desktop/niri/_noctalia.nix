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
      "XF86AudioRaiseVolume" = locked "Volume up" ["volume-up"];
      "XF86AudioLowerVolume" = locked "Volume down" ["volume-down"];
      "XF86AudioMute" = locked "Mute" ["volume-mute"];
      "XF86MonBrightnessUp" = locked "Brightness up" ["brightness-up"];
      "XF86MonBrightnessDown" = locked "Brightness down" ["brightness-down"];
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
