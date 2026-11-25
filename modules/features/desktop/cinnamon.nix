{
  flake.modules.nixos.os-desktop-cinnamon =
    # Cinnamon on X11: Windows-like out of the box (bottom panel, start menu).
    # Power and screensaver defaults below; users' own settings win.
    {
      services.xserver = {
        enable = true;
        desktopManager.cinnamon = {
          enable = true;
          # Blank after 5 min idle, lock 5 min later; screen off at 15 (AC) / 10
          # (battery) min, suspend at 30 / 15. Lock on suspend; shut down at 10%
          # battery (Cinnamon's default, hibernate, needs disk swap).
          extraGSettingsOverrides = ''
            [org.cinnamon.desktop.session]
            idle-delay=300

            [org.cinnamon.desktop.screensaver]
            lock-enabled=true
            lock-delay=300

            [org.cinnamon.settings-daemon.plugins.power]
            sleep-display-ac=900
            sleep-display-battery=600
            sleep-inactive-ac-timeout=1800
            sleep-inactive-ac-type='suspend'
            sleep-inactive-battery-timeout=900
            sleep-inactive-battery-type='suspend'
            lock-on-suspend=true
            critical-battery-action='shutdown'
            use-time-for-policy=false
            percentage-action=10
          '';
        };
      };
      services.displayManager.defaultSession = "cinnamon";
    };
}
