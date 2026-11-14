# Niri session, terminal greeter and Noctalia shell.
{pkgs, ...}: {
  programs.niri.enable = true;
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    recommendedServices.enable = true;
  };
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
      user = "greeter";
    };
  };
  environment.systemPackages = with pkgs; [foot fuzzel xwayland-satellite];
}
