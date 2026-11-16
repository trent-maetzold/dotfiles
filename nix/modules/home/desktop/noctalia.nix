# Noctalia's idle behaviour: screen off at 5 min, lock at 10, suspend at 15
# on battery only (never while plugged in). Lock before any suspend, lid
# included. Noctalia reads every *.toml here; its Settings UI can override.
{pkgs, ...}: let
  suspendOnBattery = pkgs.writeShellScript "suspend-on-battery" ''
    ${pkgs.systemd}/bin/systemd-ac-power || exec ${pkgs.systemd}/bin/systemctl suspend
  '';
in {
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
