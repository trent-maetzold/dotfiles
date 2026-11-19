{
  config,
  inputs,
  lib,
  ...
}: let
  loginHost = "hs.trkm.io";
  loginServer = "https://${loginHost}";
  tailnetDomain = "ts.trkm.io";
  tailnetAddress = "100.64.0.6";
  dashboardAddress = "127.0.0.1:8081";

  # These HTTP routes are tailnet-only; Paseo is served separately over TCP.
  httpBackends = {
    hermes = "http://100.64.0.2:8787";
    "dash.hermes" = "http://100.64.0.2:9119";
    "gw.hermes" = "http://100.64.0.2:8642";
    magpie = "http://100.64.0.2:3430";
    traefik = "http://${dashboardAddress}";
    "yggdrasil-bmc" = "https://10.10.20.154:443";
  };
  routeHost = name:
    if name == "yggdrasil-bmc"
    then "bmc.yggdrasil.${tailnetDomain}"
    else "${name}.${tailnetDomain}";
  inherit (config.sops) secrets;
in {
  imports = [inputs.sops-nix.nixosModules.sops];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age = {
      keyFile = "/var/lib/age/key.txt";
      sshKeyPaths = [];
    };
    gnupg.sshKeyPaths = [];
    secrets = {
      ts-authkey.key = "tailscale/ts-authkey";
      headplane-cookie-secret = {
        key = "headscale/headplane-cookie-secret";
        owner = "headscale";
      };
      cf-dns-api-token = {
        key = "traefik/cf-dns-api-token";
        owner = "traefik";
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [80 443];
    trustedInterfaces = ["tailscale0"];
  };

  services.tailscale = {
    enable = true;
    authKeyFile = secrets.ts-authkey.path;
    extraUpFlags = ["--login-server=${loginServer}"];
    extraSetFlags = ["--netfilter-mode=off" "--accept-routes"];
  };

  services.headscale = {
    enable = true;
    settings = {
      server_url = loginServer;
      dns = {
        magic_dns = true;
        base_domain = tailnetDomain;
        nameservers.global = ["1.1.1.1" "9.9.9.9"];
        extra_records = map (name: {
          name = routeHost name;
          type = "A";
          value = tailnetAddress;
        }) (builtins.attrNames (httpBackends // {paseo = null;}));
      };
    };
  };

  services.headplane = {
    enable = true;
    settings = {
      server = {
        base_url = "${loginServer}/admin";
        cookie_secret_path = secrets.headplane-cookie-secret.path;
      };
      headscale.config_path = config.services.headscale.configFile;
    };
  };

  systemd.services.traefik.environment.CF_DNS_API_TOKEN_FILE = secrets.cf-dns-api-token.path;
  services.traefik = {
    enable = true;

    staticConfigOptions = {
      api = {
        insecure = true;
        disableDashboardAd = true;
      };
      log.level = "INFO";
      accessLog = {};

      entryPoints = {
        web = {
          address = ":80";
          http.redirections.entryPoint.to = "websecure";
        };
        traefik.address = dashboardAddress;
        websecure = {
          address = ":443";
          asDefault = true;
          http.tls.certResolver = "cloudflare";
        };
        # Headscale HTTPS must start before Heimdall has its tailnet address.
        paseo.address = ":6767";
      };

      certificatesResolvers.cloudflare.acme = {
        email = "tkm89@proton.me";
        storage = "${config.services.traefik.dataDir}/acme.json";
        dnsChallenge = {
          provider = "cloudflare";
          # MagicDNS answers SOA for tailnet names with NOTIMP.
          resolvers = ["1.1.1.1:53"];
        };
      };
    };

    dynamicConfigOptions = {
      http = {
        middlewares = {
          tailnet.ipAllowList.sourceRange = ["100.64.0.0/10"];
          headplane.redirectRegex = {
            regex = ".*";
            replacement = "${loginServer}/admin";
          };
          # Dashboard assets are relative to /dashboard/.
          dashboard.redirectRegex = {
            regex = "^(https?://[^/]+)/(dashboard)?$";
            replacement = "\${1}/dashboard/";
            permanent = true;
          };
        };

        routers =
          lib.mapAttrs (name: _: {
            rule = "Host(`${routeHost name}`)";
            service = name;
            middlewares = ["tailnet"] ++ lib.optional (name == "traefik") "dashboard";
          })
          httpBackends
          // {
            root = {
              rule = "Host(`${loginHost}`) && Path(`/`)";
              service = "noop@internal";
              middlewares = ["headplane"];
            };
            headplane = {
              rule = "Host(`${loginHost}`) && PathPrefix(`/admin`)";
              service = "headplane";
            };
            headscale = {
              rule = "Host(`${loginHost}`)";
              service = "headscale";
            };
          };

        services =
          lib.mapAttrs (name: url: {
            loadBalancer =
              {servers = [{inherit url;}];}
              // lib.optionalAttrs (name == "yggdrasil-bmc") {serversTransport = name;};
          }) (httpBackends
            // {
              headplane = "http://127.0.0.1:${toString config.services.headplane.settings.server.port}";
              headscale = "http://127.0.0.1:${toString config.services.headscale.port}";
            });
        serversTransports.yggdrasil-bmc.insecureSkipVerify = true;
      };

      tcp = {
        routers.paseo = {
          entryPoints = ["paseo"];
          rule = "ClientIP(`100.64.0.0/10`)";
          service = "paseo";
        };
        services.paseo.loadBalancer.servers = [{address = "100.64.0.2:6767";}];
      };
    };
  };
}
