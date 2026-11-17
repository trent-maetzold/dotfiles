# A machine we don't build, reached through the `via` host's subnet router:
# `route` for `routes.<n>`, `host` for `flake.hosts.<name>`, `nixosModule` for
# `flake.nixosModules.<via>`, advertising its address. The rest is
# makeServiceRoute's.
{config, ...}: let
  inherit (config.flake.lib) makeHost makeServiceRoute;
in {
  flake.lib.makeSubnetRoute = {
    name,
    via,
    address,
    ssh ? {},
    ...
  } @ args: {
    route = makeServiceRoute (removeAttrs args ["name" "via" "address" "ssh"] // {ip = address;});

    host = makeHost {
      inherit name address;
      ssh.${name} = {ProxyJump = via;} // ssh;
    };

    nixosModule.tailscale.subnetRoutes = ["${address}/32"];
  };
}
