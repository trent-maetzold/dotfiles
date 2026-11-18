{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (inputs) hermes-agent hermes-webui;
  cfg = config.services.hermes-agent;
  inherit (config.sops.secrets) deepseek-api-key opencode-api-key hermes-api-server-key hermes-dashboard-password;
  secretEnv = import ./secret-env.nix {inherit lib pkgs;};
  gateway = secretEnv "hermes-agent" {
    DEEPSEEK_API_KEY = deepseek-api-key.path;
    OPENCODE_GO_API_KEY = opencode-api-key.path;
    API_SERVER_KEY = hermes-api-server-key.path;
  };
  backend = secretEnv "hermes-backend" {
    HERMES_DASHBOARD_BASIC_AUTH_PASSWORD = hermes-dashboard-password.path;
  };
  # plugin.yaml must sit at the package root.
  plugin = name: src: pkgs.runCommand name {} "cp -r ${src} $out";
  dashboard = "https://dash.hermes.ts.trkm.io";
in {
  imports = [hermes-agent.nixosModules.default hermes-webui.nixosModules.default];

  sops.secrets = {
    deepseek-api-key.key = "shared/deepseek-api-key";
    hermes-api-server-key.key = "hermes/hermes-api-server-key";
    hermes-dashboard-password.key = "hermes/hermes-dashboard-password";
    opencode-api-key.key = "hermes/opencode-api-key";
  };

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
    enable = true;
    addToSystemPackages = true;
    # Upstream reports 0.0.0, failing plugins' requires_hermes checks.
    package = hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default.override {version = "0.22.2";};

    backend = {
      mode = "dashboard";
      host = "100.64.0.2";
      port = 9119;
    };

    extraPlugins = [
      (plugin "honcho" "${inputs.honcho}/hermes-plugin-honcho")
      (plugin "omh" "${inputs.oh-my-hermes}/src/plugin_bundle/omh")
      (plugin "hermex-push" "${inputs.hermex-push}/plugin")
    ];
    extraPythonPackages = [
      (cfg.package.python.pkgs.callPackage ./honcho-ai.nix {inherit (pkgs) fetchPypi;})
    ];
    hermesHomeFiles."honcho.json" = builtins.toJSON {
      baseUrl = "http://127.0.0.1:8000";
      hosts.hermes = {
        enabled = true;
        aiPeer = "hermes";
        peerName = "tm";
        workspace = "hermes";
      };
    };

    environment = {
      API_SERVER_ENABLED = "true";
      API_SERVER_HOST = "100.64.0.2";
      API_SERVER_PORT = "8642";
      HERMEX_PUSH_RELAY_URL = "https://hermex-relay.hermex-relay.workers.dev";
    };

    settings = {
      approvals.deny = ["git push --force*" "*curl*|*sh*" "*wget*|*sh*"];
      checkpoints.enabled = true;
      dashboard = {
        basic_auth.username = "tm";
        public_url = dashboard;
      };
      webui.dashboard.url = dashboard;
      memory = {
        write_approval = true;
        # extraPlugins are linked as nix-managed-<name>.
        provider = "nix-managed-honcho";
      };
      plugins.enabled = ["omh" "hermex-push"];
      privacy.redact_pii = true;
      skills = {
        guard_agent_created = true;
        write_approval = true;
      };
    };
  };

  services.hermes-webui = {
    enable = true;
    host = "100.64.0.2";
    port = 8787;
    inherit (cfg) user group;
    hermesHome = "${cfg.stateDir}/.hermes";
    stateDir = "${cfg.stateDir}/.hermes-webui";
    agent.package = cfg.package;
  };
}
