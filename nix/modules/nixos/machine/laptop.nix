# Suspend on lid close, whatever the power source; never on idle.
{
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "suspend";
    IdleAction = "ignore";
  };
}
