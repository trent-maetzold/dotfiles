{
  config,
  inputs,
  lib,
  username,
  workEmail,
  ...
}: let
  hm = config.flake.modules.homeManager;
  system = "x86_64-linux"; # standalone profiles only; NixOS brings its own pkgs

  # Every profile is the full `default` feature set plus overrides.
  profiles = {
    default = {};
    work.dotfiles.git.email = workEmail;
  };

  homeModule = override: {imports = [hm.default override];};
in {
  # Standalone: `home-manager switch --flake .#<profile>`.
  flake.homeConfigurations = lib.mapAttrs (_: override:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      modules = [
        (homeModule override)
        {
          home = {
            inherit username;
            homeDirectory = "/home/${username}";
          };
          programs.home-manager.enable = true;
        }
      ];
    })
  profiles;

  # For importing into another home-manager config.
  flake.homeModules = lib.mapAttrs (_: homeModule) profiles;

  # For downstream NixOS flakes: the same setup for one user.
  flake.nixosModules =
    lib.mapAttrs (_: override: {config, ...}: {
      imports = [inputs.home-manager.nixosModules.home-manager];

      options.dotfiles.user = lib.mkOption {
        type = lib.types.str;
        default = username;
        description = "User who gets the dotfiles home-manager setup.";
      };

      config.home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${config.dotfiles.user}.imports = [(homeModule override)];
      };
    })
    profiles;
}
