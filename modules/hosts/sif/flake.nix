{
  inputs,
  config,
  ...
}: {
  flake.modules.nixos.sif = import ./default.nix {inherit (config.flake.modules) nixos;};
  flake.nixosConfigurations.sif = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {inherit inputs;};
    modules = [config.flake.modules.nixos.sif];
  };
}
