# Paseo daemon on loopback, on the tailnet at paseo.<tailnet domain>, and
# through its hosted relay. Reusable as `asgard.modules.nixos.paseo`, activated
# as `asgard.nixosModules.yggdrasil`.
{
  config,
  lib,
  paseo,
  ...
}: let
  port = 6767;

  modules.nixos = _: {
    imports = [paseo.nixosModules.default];

    services.paseo = {
      enable = true;
      listenAddress = lib.mkDefault "127.0.0.1";
      inherit port;
      openFirewall = false;
      hostnames = [];

      relay = {
        enable = true;
        mode = "hosted";
        host = "";
        port = 443;
        useTls = true;
        publicUseTls = null;
      };

      environment = {};
      settings = {};
    };
  };

  route = config.flake.lib.makeServiceRoute {
    hostname = "paseo.ts.trkm.io";
    ip = config.hosts.yggdrasil.ips.tailnet;
    inherit port;
    scheme = "tcp";
  };

  hosts.yggdrasil = {pkgs, ...}: {
    environment.systemPackages = [pkgs.llm-agents.prime-agent pkgs.autolith];

    # As tm, agents get its CLIs on PATH and their logins in its home.
    services.paseo = {
      user = "tm";
      group = "users";
      hostnames = [route.hostname];
      listenAddress = route.endpoint.ip;
      inherit (route.endpoint) port;

      settings = {
        version = 1;
        daemon = {
          cors.allowedOrigins = ["https://app.paseo.sh"];
          relay.enabled = false;
        };

        app.baseUrl = "https://app.paseo.sh";
        agents.providers = {
          prime-agent = {
            extends = "acp";
            label = "Prime Agent";
            description = "Prime Intellect self-improving RLM agent";
            command = ["prime-agent" "--mode" "acp"];
          };

          autolith = {
            extends = "acp";
            label = "Autolith";
            description = "Live, self-modifying Common Lisp agent";
            command = ["autolith" "acp"];
          };

          muse.enabled = false;
          antigravity.enabled = false;
          opencode.enabled = false;
          copilot.enabled = false;
        };
      };
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.paseo = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.yggdrasil.imports = [
    config.flake.modules.nixos.paseo
    hosts.yggdrasil
  ];

  # Routes
  routes.paseo = route;
}
