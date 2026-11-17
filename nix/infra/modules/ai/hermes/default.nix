# Hermes Agent with its dashboard; hermes-webui shares its HERMES_HOME. On
# yggdrasil the web UI, dashboard and gateway API listen on its tailnet IP for
# the router.
{
  config,
  lib,
  hermes-agent,
  hermes-webui,
  ...
}: let
  inherit (config.flake.lib) makeEnvFile makeServiceRoute;

  ports = {
    dashboard = 9119;
    gateway = 8642;
    webui = 8787;
  };

  modules.nixos = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.services.hermes-agent;
  in {
    imports = [hermes-agent.nixosModules.default hermes-webui.nixosModules.default];

    services = {
      hermes-agent = {
        enable = true;
        addToSystemPackages = true;
        # Upstream builds report 0.0.0, failing plugins' `requires_hermes`; bump with the input.
        package = hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default.override {version = "0.22.2";};

        backend = {
          mode = "dashboard";
          host = lib.mkDefault "127.0.0.1";
          port = lib.mkDefault ports.dashboard;
        };

        environment = {
          API_SERVER_HOST = lib.mkDefault "127.0.0.1";
          API_SERVER_PORT = lib.mkDefault (toString ports.gateway);
        };
      };

      hermes-webui = {
        enable = true;
        host = lib.mkDefault "127.0.0.1";
        port = lib.mkDefault ports.webui;
        inherit (cfg) user group;
        hermesHome = "${cfg.stateDir}/.hermes";
        stateDir = "${cfg.stateDir}/.hermes-webui";
        agent.package = cfg.package;
      };
    };
  };

  ip = config.hosts.yggdrasil.ips.tailnet;

  routes = {
    hermes = makeServiceRoute {
      hostname = "hermes.ts.trkm.io";
      inherit ip;
      port = ports.webui;
    };

    "dash.hermes" = makeServiceRoute {
      hostname = "dash.hermes.ts.trkm.io";
      inherit ip;
      port = ports.dashboard;
    };

    "gw.hermes" = makeServiceRoute {
      hostname = "gw.hermes.ts.trkm.io";
      inherit ip;
      port = ports.gateway;
    };
  };

  user = config.flake.users.tm.name;
  dashboard = "https://${routes."dash.hermes".hostname}";

  hosts.yggdrasil = {
    config,
    pkgs,
    ...
  }: let
    inherit (config.sops.secrets) deepseek-api-key opencode-api-key hermes-api-server-key hermes-dashboard-password;
    gateway = makeEnvFile {
      inherit pkgs;
      name = "hermes-agent";
      vars = {
        DEEPSEEK_API_KEY = deepseek-api-key.path;
        OPENCODE_GO_API_KEY = opencode-api-key.path;
        API_SERVER_KEY = hermes-api-server-key.path;
      };
    };
    backend = makeEnvFile {
      inherit pkgs;
      name = "hermes-backend";
      vars.HERMES_DASHBOARD_BASIC_AUTH_PASSWORD = hermes-dashboard-password.path;
    };
  in {
    sops.secrets = {
      deepseek-api-key.key = "shared/deepseek-api-key";
      hermes-api-server-key.key = "hermes/hermes-api-server-key";
      hermes-dashboard-password.key = "hermes/hermes-dashboard-password";
      opencode-api-key.key = "hermes/opencode-api-key";
    };

    # Process env, which hermes reads beside its .env.
    systemd.services = {
      hermes-agent.serviceConfig = {
        inherit (gateway) ExecStartPre;
        EnvironmentFile = "-${gateway.file}";
      };

      hermes-backend.serviceConfig = {
        inherit (backend) ExecStartPre;
        EnvironmentFile = "-${backend.file}";
      };
    };

    services.hermes-agent = {
      backend = {
        host = routes."dash.hermes".endpoint.ip;
        inherit (routes."dash.hermes".endpoint) port;
      };

      extraPlugins = with pkgs; [omh hermex-push-plugin];

      environment = {
        API_SERVER_ENABLED = "true";
        API_SERVER_HOST = routes."gw.hermes".endpoint.ip;
        API_SERVER_PORT = toString routes."gw.hermes".endpoint.port;
        # Hermex's relay; only its developer holds the APNs key, so it can't be self-hosted
        HERMEX_PUSH_RELAY_URL = "https://hermex-relay.hermex-relay.workers.dev";
      };

      # Non-default config.yaml keys
      settings = {
        approvals.deny = ["git push --force*" "*curl*|*sh*" "*wget*|*sh*"];
        checkpoints.enabled = true;

        dashboard = {
          basic_auth.username = user;
          public_url = dashboard;
        };

        # hermes-webui's dashboard link
        webui.dashboard.url = dashboard;

        memory.write_approval = true;
        plugins.enabled = ["omh" "hermex-push"];
        privacy.redact_pii = true;

        skills = {
          guard_agent_created = true;
          write_approval = true;
        };
      };
    };

    services.hermes-webui = {
      host = routes.hermes.endpoint.ip;
      inherit (routes.hermes.endpoint) port;
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.hermes = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.yggdrasil.imports = [
    config.flake.modules.nixos.hermes
    hosts.yggdrasil
  ];

  # Routes
  inherit routes;
}
