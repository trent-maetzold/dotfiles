# Traefik routers and services for http(s) routes: tailnet ones behind the tailnet middleware.
{lib}: allRoutes: let
  routes = lib.filterAttrs (_: route: route.endpoint.scheme != "tcp") allRoutes;
in {
  routers =
    lib.mapAttrs (name: route: {
      rule = "Host(`${route.hostname}`)";
      service = name;
      middlewares = lib.optional (!route.public) "tailnet";
    })
    routes;

  services =
    lib.mapAttrs (name: route: {
      loadBalancer =
        {servers = [{url = "${route.endpoint.scheme}://${route.endpoint.ip}:${toString route.endpoint.port}";}];}
        // lib.optionalAttrs (route.endpoint.scheme == "https") {serversTransport = name;};
    })
    routes;

  serversTransports = lib.mapAttrs (_: _: {insecureSkipVerify = true;}) (lib.filterAttrs (_: route: route.endpoint.scheme == "https") routes);
}
