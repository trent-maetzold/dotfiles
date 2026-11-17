# A machine this flake knows: its addresses and ssh entries. Pass `system` and
# it also gets its NixOS parts.
{
  lib,
  nixpkgs,
  ...
}: {
  flake.lib.makeHost = {
    name,
    system ? null,
    imports ? [],
    users ? [],
    specialArgs ? {},
    address ? name,
    hostId ? null,
    tailnetIp ? null,
    lan ? {},
    ssh ? {},
  }: let
    # The interfaces bond into bond0 behind br0, which holds the address.
    iface =
      if lan.interfaces or [] == []
      then "eth0"
      else "br0";

    nixosModule = {options, ...}: {
      imports = imports ++ map (u: u.nixosModule) users;

      config = lib.mkMerge [
        {
          nixpkgs.hostPlatform = system;
          networking.hostName = name;
        }
        (lib.mkIf (hostId != null) {networking.hostId = hostId;})
        (lib.mkIf (lan ? gateway) {
          networking =
            {
              defaultGateway = lan.gateway;
              nameservers = lan.nameservers or [];
              interfaces.${iface}.ipv4.addresses = [{inherit (lan) address prefixLength;}];
            }
            // lib.optionalAttrs (iface == "br0") {
              bonds.bond0.interfaces = lan.interfaces;
              bridges.br0.interfaces = ["bond0"];
            };
        })
        (lib.optionalAttrs (options ? wsl && users != []) {wsl.defaultUser = (lib.head users).name;})
      ];
    };
  in
    {
      inherit name tailnetIp lan;

      ssh = lib.recursiveUpdate ({${name}.HostName = address;} // lib.optionalAttrs (lan ? address) {"${name}-lan".HostName = lan.address;}) ssh;
    }
    // lib.optionalAttrs (system != null) {
      inherit system nixosModule specialArgs;

      nixosConfiguration = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [nixosModule];
      };
    };
}
