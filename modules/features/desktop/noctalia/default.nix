{
  flake.modules.nixos.noctalia = {
    # Noctalia loads its defaults, then GUI changes from ~/.local/state/noctalia/settings.toml.
    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      recommendedServices.enable = true;
    };
  };
}
