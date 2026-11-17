# Machines we reach but don't build, each adding itself to the host it is
# reached through.
{config, ...}: let
  inherit (config.flake.lib) makeSubnetRoute;

  # Out of band, with a certificate of its own.
  bmc = makeSubnetRoute {
    name = "yggdrasil-bmc";
    via = "yggdrasil";
    address = "10.10.20.154";
    hostname = "bmc.yggdrasil.ts.trkm.io";
    port = 443;
    scheme = "https";
    ssh.User = "root";
  };
in {
  flake.hosts.yggdrasil-bmc = bmc.host;
  routes.yggdrasil-bmc = bmc.route;
  flake.nixosModules.yggdrasil.imports = [bmc.nixosModule];
}
