# Noctalia's default idle timings, enabled for the desktop session. GUI
# overrides remain possible in ~/.local/state/noctalia/settings.toml.
{pkgs, ...}: let
  suspendOnBattery = pkgs.writeShellScript "noctalia-suspend-on-battery" ''
    # Keep watching after the idle timeout, so unplugging while already idle
    # still suspends. A failed power query must never trigger suspension.
    while true; do
      if [ "$(${pkgs.systemd}/bin/busctl --system get-property org.freedesktop.UPower /org/freedesktop/UPower org.freedesktop.UPower OnBattery 2>/dev/null)" = "b true" ]; then
        exec ${pkgs.noctalia}/bin/noctalia msg session lock-and-suspend
      fi
      ${pkgs.coreutils}/bin/sleep 5
    done
  '';
in {
  systemd.user.services.noctalia-suspend-on-battery = {
    Unit.Description = "Suspend an idle session on battery power";
    Service.ExecStart = suspendOnBattery;
  };

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
    action = "command"
    command = "${pkgs.systemd}/bin/systemctl --user start --no-block noctalia-suspend-on-battery.service"
    resume_command = "${pkgs.systemd}/bin/systemctl --user stop --no-block noctalia-suspend-on-battery.service"
  '';
}
