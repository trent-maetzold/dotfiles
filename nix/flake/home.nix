{
  inputs,
  config,
  ...
}: let
  mkHome = features:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        config.flake.homeModules.default
        {
          home = {
            username = "trent";
            homeDirectory = "/home/trent";
            stateVersion = "26.05";
          };
          dotfiles = features;
        }
      ];
    };
in {
  flake.homeConfigurations = {
    # Omarchy desktop: everything.
    trent = mkHome {
      git.enable = true;
      nvim.enable = true;
      magpie.enable = true;
      paseo.enable = true;
    };
    # No containers (no podman needed): for work.
    trent-lite = mkHome {
      git.enable = true;
      nvim.enable = true;
    };
  };
}
