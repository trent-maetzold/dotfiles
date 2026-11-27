{
  flake.modules.homeManager.umbriel =
    # The NixOS module supplies the session; Home Manager writes host settings.
    {
      config,
      lib,
      umbriel,
      ...
    }: {
      imports = [umbriel.homeModules.default];

      programs.umbriel = {
        enable = true;
        settings = {
          include.files = ["/etc/xdg/umbriel/config.toml"];
          keybinds."Mod+Shift+Slash" = "cheatsheet-toggle";
          input.cursor = lib.mkIf config.home.pointerCursor.enable {
            theme = config.home.pointerCursor.name;
            size = config.home.pointerCursor.size;
          };
        };
      };
    };
  flake.modules.nixos.umbriel =
    # Supply the Umbriel session.
    {
      config,
      inputs,
      ...
    }: {
      imports = [inputs.umbriel.nixosModules.default];

      programs.umbriel.enable = true;
      environment.etc."xdg/umbriel/config.toml".source = "${config.programs.umbriel.package}/share/umbriel/config.toml";
    };
}
