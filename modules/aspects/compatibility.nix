{config, ...}: let
  inherit (config.flake.modules) homeManager nixos;
in {
  # Keep the module paths used by flakes that consume the original bundles.
  flake.nixosModules.default = nixos.defaultProfile;

  flake.homeModules.default = {
    imports = [
      homeManager.defaultProfile
      ({
        config,
        lib,
        pkgs,
        user,
        ...
      }: let
        identity = {
          name = user.fullName;
          inherit (user) email;
        };
      in {
        options.services.magpie.enable = lib.mkEnableOption "the legacy Magpie CLI gateway";
        config = lib.mkMerge [
          {
            programs.git.settings.user = identity;
            programs.jujutsu.settings.user = identity;
          }
          (lib.mkIf config.services.magpie.enable (homeManager.magpie-cli {inherit config pkgs;}))
        ];
      })
    ];
  };

  flake.homeModules.desktop = {
    imports = with homeManager; [
      desktopProfile
      desktop-magpie
      umbriel
      noctalia
    ];
    programs.umbriel.settings.keybinds = {
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
      "Mod+Ctrl+L" = "spawn noctalia msg session lock";
    };
  };
}
