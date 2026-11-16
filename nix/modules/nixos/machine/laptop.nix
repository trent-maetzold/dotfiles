# Suspend on lid close, whatever the power source; idle sleep is left to the
# desktop. Power modes (power-profiles-daemon) and Intel thermal management.
{
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "suspend";
    IdleAction = "ignore";
  };
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;
}
