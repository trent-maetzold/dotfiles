# Umbriel session. The Noctalia shell and greeter come from noctalia.nix.
{inputs, ...}: {
  imports = [
    inputs.umbriel.nixosModules.default
    ./noctalia.nix
  ];

  programs.umbriel.enable = true;
  # Keyring for apps' saved logins (gh, ...), unlocked at login.
  services.gnome.gnome-keyring.enable = true;
}
