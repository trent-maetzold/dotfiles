# Changes to Niri's default bindings (later binds override the defaults').
# Workspaces move from U/I to J/K; window and monitor up/down stay on the
# arrow keys.
{
  wayland.windowManager.niri.settings.binds = {
    "Mod+T" = {
      _props.hotkey-overlay-title = "Open a Terminal: foot";
      spawn = ["foot"];
    };
    "Mod+J".focus-workspace-down = {};
    "Mod+K".focus-workspace-up = {};
    "Mod+Ctrl+J".move-column-to-workspace-down = {};
    "Mod+Ctrl+K".move-column-to-workspace-up = {};
    "Mod+Shift+J".move-workspace-down = {};
    "Mod+Shift+K".move-workspace-up = {};
  };
}
