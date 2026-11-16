# Changes to Niri's default bindings (later binds override the defaults').
{
  wayland.windowManager.niri.settings.binds = {
    "Mod+T" = {
      _props.hotkey-overlay-title = "Open a Terminal: foot";
      spawn = ["foot"];
    };
  };
}
