# Changes to Niri's default bindings (later binds override the defaults').
# J/K mirror H/L with workspaces as the vertical axis: Mod focuses, Ctrl
# moves the column, Shift (default) focuses the monitor. U/I take window
# up/down (Mod focuses, Ctrl moves) and Shift moves the workspace.
{
  wayland.windowManager.niri.settings.binds = {
    "Mod+T" = {
      _props.hotkey-overlay-title = "Open a Terminal: Ghostty";
      spawn = ["ghostty"];
    };
    "Mod+Return" = {
      _props.hotkey-overlay-title = "Open a Terminal: Ghostty";
      spawn = ["ghostty"];
    };
    "Mod+B" = {
      _props.hotkey-overlay-title = "Browser: Zen";
      spawn = ["zen-beta"];
    };
    "Mod+J".focus-workspace-down = {};
    "Mod+K".focus-workspace-up = {};
    "Mod+Ctrl+J".move-column-to-workspace-down = {};
    "Mod+Ctrl+K".move-column-to-workspace-up = {};
    "Mod+U".focus-window-down = {};
    "Mod+I".focus-window-up = {};
    "Mod+Ctrl+U".move-window-down = {};
    "Mod+Ctrl+I".move-window-up = {};
    "Mod+Shift+U".move-workspace-down = {};
    "Mod+Shift+I".move-workspace-up = {};
  };
}
