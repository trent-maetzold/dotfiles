{config, ...}: let
  noctalia = config.flake.modules.nixos.umbriel-noctalia;
in {
  flake.modules.homeManager.umbriel =
    # The NixOS module supplies the session; Home Manager writes host settings.
    {
      config,
      umbriel,
      ...
    }: {
      imports = [umbriel.homeModules.default];

      programs.umbriel = {
        enable = true;
        settings = {
          include.files = ["/etc/xdg/umbriel/config.toml"];
          keybinds = {
            "Mod+Return" = {
              action = "spawn ghostty";
              repeat = false;
            };
            "Mod+B" = {
              action = "spawn luakit";
              repeat = false;
            };
            "Mod+Shift+B" = {
              action = "spawn zen-beta";
              repeat = false;
            };
            "Mod+Shift+Slash" = "cheatsheet-toggle";
            "Mod+Ctrl+L" = "spawn noctalia msg session lock";
          };
          input.cursor = {
            theme = config.home.pointerCursor.name;
            size = config.home.pointerCursor.size;
          };
        };
      };
    };
  flake.modules.nixos.umbriel =
    # Umbriel session. The Noctalia shell and greeter come from noctalia.nix.
    {
      config,
      inputs,
      ...
    }: {
      imports = [
        inputs.umbriel.nixosModules.default
        noctalia
      ];

      programs.umbriel.enable = true;
      environment.etc."xdg/umbriel/config.toml".source = "${config.programs.umbriel.package}/share/umbriel/config.toml";
      # Keyring for apps' saved logins (gh, ...), unlocked at login.
      services.gnome.gnome-keyring.enable = true;
    };
}
