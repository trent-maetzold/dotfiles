{
  inputs,
  config,
  ...
}: let
  inherit (inputs) self nixpkgs home-manager;
  trent = import ../../users/trent/identity.nix;
in {
  flake.modules.nixos.muninn = import ./default.nix {inherit (config.flake.modules) nixos;};
  flake.nixosConfigurations.muninn = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
      user = trent;
    };
    modules = [
      config.flake.modules.nixos.muninn
      home-manager.nixosModules.home-manager
      {
        nixpkgs.overlays = [self.overlays.default];
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = inputs // {user = trent;};
          users.trent.imports = [config.flake.modules.homeManager.defaultProfile config.flake.modules.homeManager.desktopProfile (import ./home.nix)];
        };
      }
    ];
  };
}
