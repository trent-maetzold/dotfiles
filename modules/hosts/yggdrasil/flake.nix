{
  inputs,
  config,
  ...
}: {
  flake.modules.nixos.yggdrasil = import ./default.nix;
  flake.nixosConfigurations.yggdrasil = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
      user = import ../../users/trent/identity.nix;
    };
    modules = [
      ./default.nix
      inputs.home-manager.nixosModules.home-manager
      {home-manager.users.trent.imports = [config.flake.modules.homeManager.defaultProfile];}
    ];
  };
}
