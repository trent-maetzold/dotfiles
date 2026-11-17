# Honcho memory server: API, deriver, PostgreSQL (pgvector) and Valkey on the
# `honcho` network, reaching each other by container name; only the API is
# published, on the host's loopback. `honcho-db-password` is the database
# password's file.
#
# On yggdrasil it is hermes' memory. Generation runs on DeepSeek V4.1 Flash via
# the DeepSeek API; embeddings on OpenRouter (the openai transport's
# LLM_OPENAI_API_KEY), at Honcho's 1536 dimensions.
{
  config,
  lib,
  quadlet-nix,
  ...
}: let
  inherit (config.flake.lib) makeEnvFile;

  endpoint = {
    host = "127.0.0.1";
    port = 8000;
  };

  modules.nixos = {
    config,
    pkgs,
    honcho-db-password,
    ...
  }: let
    inherit (config.virtualisation.quadlet) networks volumes;

    db = makeEnvFile {
      inherit pkgs;
      name = "honcho-db";
      vars.POSTGRES_PASSWORD = honcho-db-password;
    };
    apiEnv = makeEnvFile {
      inherit pkgs;
      name = "honcho-api";
      vars.PGPASSWORD = honcho-db-password;
    };
    service = {
      inherit (apiEnv) ExecStartPre;
      Restart = "always";
    };

    api = {
      name = "honcho-api";
      networks = [networks.honcho.ref];
      image = "ghcr.io/plastic-labs/honcho:latest";
      environmentFiles = [apiEnv.file];

      environments = {
        DB_CONNECTION_URI = "postgresql+psycopg://honcho@honcho-db:5432/honcho";
        CACHE_URL = "redis://honcho-cache:6379/0?suppress=true";
        CACHE_ENABLED = "true";
      };
    };
  in {
    imports = [quadlet-nix.nixosModules.quadlet];

    virtualisation.podman.enable = true;

    virtualisation.quadlet = {
      networks.honcho = {};
      volumes.honcho_pgdata = {};

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

        # A cache: no snapshots.
        honcho-cache.containerConfig = {
          name = "honcho-cache";
          networks = [networks.honcho.ref];
          image = "docker.io/valkey/valkey:9";
          exec = "valkey-server --save ''";
        };

        # Restarts until the database accepts connections. Podman's DNAT
        # skips the host firewall, so publish on loopback only.
        honcho-api = {
          serviceConfig = service;

          containerConfig =
            api
            // {
              exec = "sh docker/entrypoint.sh";
              publishPorts = ["${endpoint.host}:${toString endpoint.port}:8000"];
            };
        };

        honcho-deriver = {
          serviceConfig = service;

          containerConfig =
            api
            // {
              name = "honcho-deriver";
              exec = "/app/.venv/bin/python -m src.deriver";
            };
        };
      };
    };
  };
  deepseek = "https://api.deepseek.com";
  user = config.flake.users.tm.name;

  models = {
    environments = {
      DERIVER_MODEL_CONFIG__TRANSPORT = "openai";
      DERIVER_MODEL_CONFIG__MODEL = "deepseek-flash";
      DERIVER_MODEL_CONFIG__OVERRIDES__BASE_URL = deepseek;
      DERIVER_MODEL_CONFIG__OVERRIDES__API_KEY_ENV = "DEEPSEEK_API_KEY";

      SUMMARY_MODEL_CONFIG__TRANSPORT = "openai";
      SUMMARY_MODEL_CONFIG__MODEL = "deepseek-flash";
      SUMMARY_MODEL_CONFIG__OVERRIDES__BASE_URL = deepseek;
      SUMMARY_MODEL_CONFIG__OVERRIDES__API_KEY_ENV = "DEEPSEEK_API_KEY";

      DREAM_DEDUCTION_MODEL_CONFIG__TRANSPORT = "openai";
      DREAM_DEDUCTION_MODEL_CONFIG__MODEL = "deepseek-flash";
      DREAM_DEDUCTION_MODEL_CONFIG__OVERRIDES__BASE_URL = deepseek;
      DREAM_DEDUCTION_MODEL_CONFIG__OVERRIDES__API_KEY_ENV = "DEEPSEEK_API_KEY";

      DREAM_INDUCTION_MODEL_CONFIG__TRANSPORT = "openai";
      DREAM_INDUCTION_MODEL_CONFIG__MODEL = "deepseek-flash";
      DREAM_INDUCTION_MODEL_CONFIG__OVERRIDES__BASE_URL = deepseek;
      DREAM_INDUCTION_MODEL_CONFIG__OVERRIDES__API_KEY_ENV = "DEEPSEEK_API_KEY";

      DIALECTIC_LEVELS__minimal__MODEL_CONFIG__TRANSPORT = "openai";
      DIALECTIC_LEVELS__minimal__MODEL_CONFIG__MODEL = "deepseek-flash";
      DIALECTIC_LEVELS__minimal__MODEL_CONFIG__OVERRIDES__BASE_URL = deepseek;
      DIALECTIC_LEVELS__minimal__MODEL_CONFIG__OVERRIDES__API_KEY_ENV = "DEEPSEEK_API_KEY";

      DIALECTIC_LEVELS__low__MODEL_CONFIG__TRANSPORT = "openai";
      DIALECTIC_LEVELS__low__MODEL_CONFIG__MODEL = "deepseek-flash";
      DIALECTIC_LEVELS__low__MODEL_CONFIG__OVERRIDES__BASE_URL = deepseek;
      DIALECTIC_LEVELS__low__MODEL_CONFIG__OVERRIDES__API_KEY_ENV = "DEEPSEEK_API_KEY";

      DIALECTIC_LEVELS__medium__MODEL_CONFIG__TRANSPORT = "openai";
      DIALECTIC_LEVELS__medium__MODEL_CONFIG__MODEL = "deepseek-flash";
      DIALECTIC_LEVELS__medium__MODEL_CONFIG__OVERRIDES__BASE_URL = deepseek;
      DIALECTIC_LEVELS__medium__MODEL_CONFIG__OVERRIDES__API_KEY_ENV = "DEEPSEEK_API_KEY";

      DIALECTIC_LEVELS__high__MODEL_CONFIG__TRANSPORT = "openai";
      DIALECTIC_LEVELS__high__MODEL_CONFIG__MODEL = "deepseek-flash";
      DIALECTIC_LEVELS__high__MODEL_CONFIG__OVERRIDES__BASE_URL = deepseek;
      DIALECTIC_LEVELS__high__MODEL_CONFIG__OVERRIDES__API_KEY_ENV = "DEEPSEEK_API_KEY";

      DIALECTIC_LEVELS__max__MODEL_CONFIG__TRANSPORT = "openai";
      DIALECTIC_LEVELS__max__MODEL_CONFIG__MODEL = "deepseek-flash";
      DIALECTIC_LEVELS__max__MODEL_CONFIG__OVERRIDES__BASE_URL = deepseek;
      DIALECTIC_LEVELS__max__MODEL_CONFIG__OVERRIDES__API_KEY_ENV = "DEEPSEEK_API_KEY";

      EMBEDDING_MODEL_CONFIG__TRANSPORT = "openai";
      EMBEDDING_MODEL_CONFIG__MODEL = "qwen/qwen3-embedding-8b";
      EMBEDDING_MODEL_CONFIG__OVERRIDES__BASE_URL = "https://openrouter.ai/api/v1";
      # Qwen3 is 4096-dimensional; ask for the schema's 1536.
      EMBEDDING_MODEL_CONFIG__DIMENSIONS_MODE = "always";
    };
  };

  hosts.yggdrasil = {
    config,
    pkgs,
    ...
  }: let
    honcho-ai = config.services.hermes-agent.package.python.pkgs.callPackage ./_lib/honcho-ai.nix {inherit (pkgs) fetchPypi;};
    keys = makeEnvFile {
      inherit pkgs;
      name = "honcho-models";
      vars = {
        DEEPSEEK_API_KEY = config.sops.secrets.deepseek-api-key.path;
        LLM_OPENAI_API_KEY = config.sops.secrets.openrouter-api-key.path;
      };
    };
    container = {
      serviceConfig = {inherit (keys) ExecStartPre;};
      containerConfig = models // {environmentFiles = [keys.file];};
    };
  in {
    sops.secrets = {
      deepseek-api-key.key = "shared/deepseek-api-key";
      honcho-db-password.key = "honcho/honcho-db-password";
      openrouter-api-key.key = "honcho/openrouter-api-key";
    };

    _module.args.honcho-db-password = config.sops.secrets.honcho-db-password.path;

    # Volumes, not the image store.
    persistence.dirs."/var/lib/containers/storage/volumes".snapshots = true;

    virtualisation.quadlet.containers = {
      honcho-api = container;
      honcho-deriver = container;
    };

    services.hermes-agent = {
      extraPlugins = lib.mkBefore [pkgs.honcho-plugin];
      extraPythonPackages = [honcho-ai];

      hermesHomeFiles."honcho.json" = builtins.toJSON {
        baseUrl = "http://${endpoint.host}:${toString endpoint.port}";
        hosts.hermes = {
          enabled = true;
          aiPeer = "hermes";
          peerName = user;
          workspace = "hermes";
        };
      };

      # extraPlugins are linked as nix-managed-<name>, and providers are found by directory
      settings.memory.provider = "nix-managed-honcho";
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.honcho = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.yggdrasil.imports = [
    config.flake.modules.nixos.honcho
    config.flake.modules.nixos.quadlet
    hosts.yggdrasil
  ];
}
