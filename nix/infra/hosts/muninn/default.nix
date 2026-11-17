# muninn: the WSL workstation.
{
  config,
  inputs,
  ...
}: let
  inherit (config.flake) nixosModules users;
in {
  flake.hosts.muninn = config.flake.lib.makeHost {
    name = "muninn";
    address = "muninn.ts.trkm.io";
    system = "x86_64-linux";
    imports = [
      nixosModules.default
      nixosModules.muninn
      ./_modules/binfmt.nix
    ];
    users = [users.tm];
    lan.address = "10.10.10.125";
    specialArgs = inputs;
  };

  flake.nixosConfigurations.muninn = config.flake.hosts.muninn.nixosConfiguration;

  flake.nixosModules.muninn = {};
}
