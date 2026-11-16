# Changes to Niri's default bindings (later binds override the defaults').
# J/K mirror H/L with workspaces as the vertical axis: Mod focuses, Ctrl
# moves the column, Shift (default) focuses the monitor. Window and
# monitor up/down move from J/K to U/I.
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
    "Mod+U".focus-window-down = {};
    "Mod+I".focus-window-up = {};
    "Mod+Ctrl+U".move-window-down = {};
    "Mod+Ctrl+I".move-window-up = {};
    "Mod+Shift+U".focus-monitor-down = {};
    "Mod+Shift+I".focus-monitor-up = {};
  };
}
