# Where hosts are and how services are reached: read by traefik and headscale.
{lib, ...}: {
  options = {
    hosts = lib.mkOption {
      type = lib.types.lazyAttrsOf (lib.types.submodule {
        options.ips.tailnet = lib.mkOption {type = lib.types.str;};
      });
      default = {};
      description = "Hosts by name, with their addresses.";
    };

    routes = lib.mkOption {
      type = lib.types.lazyAttrsOf (lib.types.submodule {
        options = {
          hostname = lib.mkOption {type = lib.types.str;};

          public = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Reachable from the internet, not only the tailnet.";
          };

          endpoint = {
            ip = lib.mkOption {type = lib.types.str;};
            port = lib.mkOption {type = lib.types.port;};

            scheme = lib.mkOption {
              type = lib.types.enum ["http" "https" "tcp"];
              default = "http";
              description = "`https` endpoints are trusted on the tailnet, so their certificate is not verified; `tcp` passes raw TCP through traefik on its own entrypoint at `port`.";
            };
          };
        };
      });
      default = {};
      description = "How each service is reached, by router name.";
    };
  };
}
