# Noctalia on Niri, from docs.noctalia.dev (compositor-settings/niri): its IPC
# binds, its settings window floating, and window activation from its
# notifications. Mod+D and Super+Alt+L replace the defaults' fuzzel and
# swaylock. Noctalia itself starts from its systemd unit (NixOS).
let
  noctalia = args: {spawn = ["noctalia" "msg"] ++ args;};
  locked = args: noctalia args // {_props.allow-when-locked = true;};
in {
  wayland.windowManager.niri.settings = {
    binds = {
      "Mod+Space" = noctalia ["panel-toggle" "launcher"];
      "Mod+D" = noctalia ["panel-toggle" "launcher"];
      "Mod+S" = noctalia ["panel-toggle" "control-center"];
      "Mod+Shift+Comma" = noctalia ["settings-toggle"];
      "Super+Alt+L" = noctalia ["session" "lock"];
      "Alt+Tab" = noctalia ["window-switcher" "hold"];
      "Alt+Shift+Tab" = noctalia ["window-switcher" "hold" "reverse"];
      "XF86AudioRaiseVolume" = locked ["volume-up"];
      "XF86AudioLowerVolume" = locked ["volume-down"];
      "XF86AudioMute" = locked ["volume-mute"];
      "XF86MonBrightnessUp" = locked ["brightness-up"];
      "XF86MonBrightnessDown" = locked ["brightness-down"];
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
}
