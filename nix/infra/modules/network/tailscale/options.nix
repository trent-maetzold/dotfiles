# `tailscale.subnetRoutes`: what a `tailscale-subnet-router` host advertises.
{
  flake.modules.nixos.tailscale-subnet-router = {lib, ...}: {
    options.tailscale.subnetRoutes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "CIDRs this host routes the tailnet to; makeSubnetRoute adds them.";
    };
  };
}
