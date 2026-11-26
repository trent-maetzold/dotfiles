{
  flake.modules.homeManager.noctalia =
    # Noctalia's default idle timings, enabled for the desktop session. GUI
    # overrides remain possible in ~/.local/state/noctalia/settings.toml.
    {...}: {
      xdg.configFile."noctalia/idle.toml".text = ''
        [lockscreen]
        lock_before_suspend = true

        [idle.behavior.lock]
        enabled = true
        timeout = 600
        action = "lock"

        [idle.behavior.screen-off]
        enabled = true
        timeout = 660
        action = "screen_off"

        [idle.behavior.lock-and-suspend]
        enabled = true
        timeout = 900
        action = "lock_and_suspend"
      '';
    };
}
