{inputs, ...}: {
  flake.modules.nixos.yggdrasil = {config, ...}: let
    agents = inputs.zoldt-agents.modules.nixos;
    address = "100.64.0.2";
    dashboard = "https://dash.hermes.ts.trkm.io";
    inherit (config.sops) secrets;
  in {
    imports = [agents.hermes agents.honcho agents.magpie agents.paseo inputs.zoldt-secrets.modules.nixos.agents];

    zoldt.agents = {
      hermes.credentials = {
        deepseek-api-key = secrets.deepseek-api-key.path;
        opencode-api-key = secrets.opencode-api-key.path;
        hermes-api-server-key = secrets.hermes-api-server-key.path;
        hermes-dashboard-password = secrets.hermes-dashboard-password.path;
      };
      honcho.credentials = {
        honcho-db-password = secrets.honcho-db-password.path;
        deepseek-api-key = secrets.deepseek-api-key.path;
        openrouter-api-key = secrets.openrouter-api-key.path;
      };
      magpie = {
        listenAddress = address;
        publicUrl = "https://magpie.ts.trkm.io";
        webKeyFile = secrets.magpie-web-key.path;
      };
    };

    services.hermes-agent = {
      backend.host = address;
      environment = {
        API_SERVER_HOST = address;
        HERMEX_PUSH_RELAY_URL = "https://hermex-relay.hermex-relay.workers.dev";
      };
      hermesHomeFiles."honcho.json" = builtins.toJSON {
        baseUrl = "http://127.0.0.1:8000";
        hosts.hermes = {
          enabled = true;
          aiPeer = "hermes";
          peerName = "trent";
          workspace = "hermes";
        };
      };
      settings = {
        dashboard.basic_auth.username = "trent";
        dashboard.public_url = dashboard;
        webui.dashboard.url = dashboard;
      };
    };
    services.hermes-webui.host = address;
    services.paseo = {
      user = "trent";
      group = "users";
      listenAddress = address;
      hostnames = ["paseo.ts.trkm.io"];
    };
  };
}
