# Muninn's Niri session, terminal greeter and Noctalia shell.
{pkgs, ...}: {
  programs.niri.enable = true;
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    recommendedServices.enable = true;
  };
  services.greetd.settings.default_session = {
    command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
    user = "greeter";
  };
  services.greetd.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "suspend";
    IdleAction = "ignore";
  };
  environment.systemPackages = with pkgs; [foot fuzzel xwayland-satellite];
  fonts.packages = with pkgs; [noto-fonts noto-fonts-color-emoji nerd-fonts.jetbrains-mono];
}
