# Each host's tailnet address, read by traefik and headscale.
{
  config,
  lib,
  ...
}: let
  makeHosts = import ./_lib/make-hosts.nix {inherit lib;};
in {
  hosts = makeHosts config.flake.hosts;
}
