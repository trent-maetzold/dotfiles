# Umbriel session. The Noctalia shell and greeter come from noctalia.nix.
{config, inputs, ...}: {
  imports = [
    inputs.umbriel.nixosModules.default
    ./noctalia.nix
  ];

  programs.umbriel.enable = true;
  environment.etc."xdg/umbriel/config.toml".source =
    "${config.programs.umbriel.package}/share/umbriel/config.toml";
  # Keyring for apps' saved logins (gh, ...), unlocked at login.
  services.gnome.gnome-keyring.enable = true;
}
