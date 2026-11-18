{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (config.virtualisation.quadlet) networks volumes;
  inherit (config.sops) secrets;
  secretEnv = import ./secret-env.nix {inherit lib pkgs;};
  db = secretEnv "honcho-db" {POSTGRES_PASSWORD = secrets.honcho-db-password.path;};
  apiEnv = secretEnv "honcho-api" {PGPASSWORD = secrets.honcho-db-password.path;};
  keys = secretEnv "honcho-models" {
    DEEPSEEK_API_KEY = secrets.deepseek-api-key.path;
    LLM_OPENAI_API_KEY = secrets.openrouter-api-key.path;
  };
  magpie = secretEnv "magpie" {MAGPIE_WEB_KEY = secrets.magpie-web-key.path;};

  deepseek = prefix: {
    "${prefix}__TRANSPORT" = "openai";
    "${prefix}__MODEL" = "deepseek-flash";
    "${prefix}__OVERRIDES__BASE_URL" = "https://api.deepseek.com";
    "${prefix}__OVERRIDES__API_KEY_ENV" = "DEEPSEEK_API_KEY";
  };
  api = {
    networks = [networks.honcho.ref];
    image = "ghcr.io/plastic-labs/honcho:latest";
    environmentFiles = [keys.file apiEnv.file];
    environments =
      {
        DB_CONNECTION_URI = "postgresql+psycopg://honcho@honcho-db:5432/honcho";
        CACHE_URL = "redis://honcho-cache:6379/0?suppress=true";
        CACHE_ENABLED = "true";
        EMBEDDING_MODEL_CONFIG__TRANSPORT = "openai";
        EMBEDDING_MODEL_CONFIG__MODEL = "qwen/qwen3-embedding-8b";
        EMBEDDING_MODEL_CONFIG__OVERRIDES__BASE_URL = "https://openrouter.ai/api/v1";
        # Request Honcho's 1536 dimensions instead of Qwen3's native 4096.
        EMBEDDING_MODEL_CONFIG__DIMENSIONS_MODE = "always";
      }
      // lib.mergeAttrsList (map deepseek [
        "DERIVER_MODEL_CONFIG"
        "SUMMARY_MODEL_CONFIG"
        "DREAM_DEDUCTION_MODEL_CONFIG"
        "DREAM_INDUCTION_MODEL_CONFIG"
        "DIALECTIC_LEVELS__minimal__MODEL_CONFIG"
        "DIALECTIC_LEVELS__low__MODEL_CONFIG"
        "DIALECTIC_LEVELS__medium__MODEL_CONFIG"
        "DIALECTIC_LEVELS__high__MODEL_CONFIG"
        "DIALECTIC_LEVELS__max__MODEL_CONFIG"
      ]);
  };
  apiService = {
    ExecStartPre = keys.ExecStartPre ++ apiEnv.ExecStartPre;
    Restart = "always";
  };
  containers = {
    honcho-db = {
      serviceConfig = {
        inherit (db) ExecStartPre;
        Restart = "always";
      };
      containerConfig = {
        name = "honcho-db";
        networks = [networks.honcho.ref];
        image = "docker.io/pgvector/pgvector:pg18";
        environmentFiles = [db.file];
        volumes = ["${volumes.honcho_pgdata.ref}:/var/lib/postgresql"];
        environments = {
          POSTGRES_USER = "honcho";
          POSTGRES_DB = "honcho";
        };
      };
    };

    honcho-cache.containerConfig = {
      name = "honcho-cache";
      networks = [networks.honcho.ref];
      image = "docker.io/valkey/valkey:9";
      exec = "valkey-server --save ''";
    };

    # Restarts until PostgreSQL is ready. Podman's DNAT bypasses the host firewall.
    honcho-api = {
      serviceConfig = apiService;
      containerConfig =
        api
        // {
          name = "honcho-api";
          exec = "sh docker/entrypoint.sh";
          publishPorts = ["127.0.0.1:8000:8000"];
        };
    };

    honcho-deriver = {
      serviceConfig = apiService;
      containerConfig =
        api
        // {
          name = "honcho-deriver";
          exec = "/app/.venv/bin/python -m src.deriver";
        };
    };

    magpie = {
      serviceConfig = {
        inherit (magpie) ExecStartPre;
        Restart = "always";
      };
      containerConfig = {
        name = "magpie";
        image = "ghcr.io/yetone/magpie:latest";
        environmentFiles = [magpie.file];
        volumes = ["${volumes.magpie.ref}:/config"];
        exec = "web --addr 0.0.0.0:3430 --no-open";
        publishPorts = ["100.64.0.2:3430:3430"];
        environments.MAGPIE_PUBLIC_URL = "https://magpie.ts.trkm.io";
      };
    };
  };
in {
  imports = [inputs.quadlet-nix.nixosModules.quadlet];

  sops.secrets = {
    honcho-db-password.key = "honcho/honcho-db-password";
    openrouter-api-key.key = "honcho/openrouter-api-key";
    magpie-web-key.key = "magpie/web-key";
  };

  virtualisation.podman.enable = true;
  virtualisation.quadlet = {
    autoUpdate.enable = true;
    networks.honcho = {};
    volumes.honcho_pgdata = {};
    volumes.magpie = {};
    containers = lib.mapAttrs (_: container:
      container
      // {
        containerConfig =
          container.containerConfig
          // {
            autoUpdate = "registry";
            timezone = "local";
          };
      })
    containers;
  };
}
