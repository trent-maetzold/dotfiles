# Traefik entrypoints, routers and services for tcp routes, one entrypoint per
# route at its port on `ip`. Without TLS there is no SNI, so the port picks the route.
{lib}: ip: allRoutes: let
  routes = lib.filterAttrs (_: route: route.endpoint.scheme == "tcp") allRoutes;
in {
  entryPoints = lib.mapAttrs (_: route: {address = "${ip}:${toString route.endpoint.port}";}) routes;

  routers =
    lib.mapAttrs (name: _: {
      entryPoints = [name];
      rule = "HostSNI(`*`)";
      service = name;
    })
    routes;

  services = lib.mapAttrs (_: route: {loadBalancer.servers = [{address = "${route.endpoint.ip}:${toString route.endpoint.port}";}];}) routes;
}
