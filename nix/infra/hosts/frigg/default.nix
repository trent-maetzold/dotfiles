# frigg: the family PC (Cinnamon, GTX 980).
{
  config,
  inputs,
  ...
}: let
  inherit (config.flake) nixosModules users;
in {
  flake.hosts.frigg = config.flake.lib.makeHost {
    name = "frigg";
    system = "x86_64-linux";
    address = "frigg.ts.trkm.io";
    imports = [
      nixosModules.default
      nixosModules.desktop
      nixosModules.nvidia
      nixosModules.frigg
      {disko.devices.disk.main.device = "/dev/nvme0n1";}
      {hardware.facter.reportPath = ./_modules/facter.json;}
      ./_modules/nvidia.nix
    ];
    users = with users; [trent justine leo violet june];
    ssh.frigg.User = "trent";
    specialArgs = inputs;
  };

  flake.nixosConfigurations.frigg = config.flake.hosts.frigg.nixosConfiguration;

  flake.nixosModules.frigg = {};
}
