# Noctalia shell and its greeter. greetd runs the greeter; its state (last
# user, synced appearance) is preserved across the tmpfs root.
{
  # No settings on purpose: Noctalia always loads its built-in defaults, then
  # GUI changes from ~/.local/state/noctalia/settings.toml.
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    recommendedServices.enable = true;
  };
  services.displayManager.noctalia-greeter = {
    enable = true;
    # Global UI scale; per-output `scales` did not take effect here.
    settings.output.scale = 1.4;
  };
  preservation.preserveAt."/persist".directories = [
    {
      directory = "/var/lib/noctalia-greeter";
      user = "greeter";
      group = "greeter";
      mode = "0750";
    }
  ];
}
