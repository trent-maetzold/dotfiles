# thor: the gaming PC, headless for now.
{
  config,
  inputs,
  ...
}: let
  inherit (config.flake) nixosModules users;
in {
  flake.hosts.thor = config.flake.lib.makeHost {
    name = "thor";
    system = "x86_64-linux";
    address = "thor.ts.trkm.io";
    imports = [
      nixosModules.default
      nixosModules.thor
      {disko.devices.disk.main.device = "/dev/nvme0n1";}
      {hardware.facter.reportPath = ./_modules/facter.json;}
    ];
    users = [users.trent];
    ssh.thor.User = "trent";
    specialArgs = inputs;
  };

  flake.nixosConfigurations.thor = config.flake.hosts.thor.nixosConfiguration;

  flake.nixosModules.thor = {};
}
