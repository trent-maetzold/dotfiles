# Noctalia shell and its greeter. greetd runs the greeter; its state (last
# user, synced appearance) is preserved across the tmpfs root.
{
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    recommendedServices.enable = true;
  };
  services.displayManager.noctalia-greeter.enable = true;
  preservation.preserveAt."/persist".directories = [
    {
      directory = "/var/lib/noctalia-greeter";
      user = "greeter";
      group = "greeter";
      mode = "0750";
    }
  ];
}
