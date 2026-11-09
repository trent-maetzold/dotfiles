{
  config,
  inputs,
  ...
}: let
  hm = config.flake.modules.homeManager;
in {
  # paseo daemon with pi (and pi-acp) installed inside it, in a container built
  # by nix. Gets its own volumes, pi's config dir and the project dirs below;
  # nothing else from the host.
  flake.modules.homeManager.paseo = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dotfiles.paseo;
    volume = config.virtualisation.quadlet.volumes.paseo.ref;
    cache = config.virtualisation.quadlet.volumes.paseo-cache.ref;
    agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

    image = pkgs.dockerTools.buildLayeredImage {
      name = "paseo";
      tag = "latest";
      contents = [
        agents.paseo
        agents.pi
        agents.pi-acp
        pkgs.bashInteractive
        pkgs.coreutils
        pkgs.git
        pkgs.cacert
        pkgs.dockerTools.binSh
        pkgs.dockerTools.usrBinEnv
        # toolchains
        pkgs.nodejs
        pkgs.python3
        pkgs.uv
        pkgs.rustc
        pkgs.cargo
        pkgs.go
        pkgs.gcc # linker for rust/cgo/native npm modules
      ];
      # keep-id runs as our uid with no passwd entry: give it a writable HOME and /tmp.
      extraCommands = ''
        mkdir -p home/agent tmp
        chmod 777 home/agent
        chmod 1777 tmp
      '';
      config = {
        Entrypoint = ["/bin/paseo-server"];
        Env = [
          "HOME=/home/agent"
          "PASEO_HOME=/home/agent/.paseo"
          "PASEO_LISTEN=0.0.0.0:6767"
          "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
          "PATH=/bin"
          # package caches live in a volume so they survive container restarts
          "CARGO_HOME=/home/agent/.cache/cargo"
          "GOPATH=/home/agent/.cache/go"
          "npm_config_cache=/home/agent/.cache/npm"
        ];
        WorkingDir = "/home/agent";
      };
    };

    paseoConfig = (pkgs.formats.json {}).generate "paseo-config.json" {
      version = 1;
      agents.providers.pi = {
        extends = "acp";
        label = "Pi";
        command = ["pi-acp"];
      };
    };

    # Mounted at the same path as on the host, so git worktree links resolve.
    mounts = map (d: "${d}:${d}:ro") cfg.readOnlyDirs ++ map (d: "${d}:${d}") cfg.writableDirs;
  in {
    options.dotfiles.paseo = {
      port = lib.mkOption {
        type = lib.types.port;
        default = 6767;
        description = "Host loopback port.";
      };
      readOnlyDirs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["${config.home.homeDirectory}/Work"];
        description = "Host dirs agents can read. Secrets must be encrypted (sops) since these are readable.";
      };
      writableDirs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["${config.home.homeDirectory}/.worktrees"];
        description = "Host dirs agents can write.";
      };
    };

    config.virtualisation.quadlet = {
      volumes.paseo = {};
      volumes.paseo-cache = {};
      containers.paseo = {
        autoStart = true;
        serviceConfig = {
          Restart = "always";
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArgs (cfg.readOnlyDirs ++ cfg.writableDirs)}";
        };
        containerConfig = {
          image = "docker-archive:${image}";
          userns = "keep-id";
          volumes =
            [
              "${volume}:/home/agent/.paseo:U"
              "${cache}:/home/agent/.cache:U"
              "${paseoConfig}:/home/agent/.paseo/config.json:ro"
              "${config.dotfiles.pi.dir}:/home/agent/.pi/agent"
            ]
            ++ mounts;
          publishPorts = ["127.0.0.1:${toString cfg.port}:6767"];
        };
      };
    };
  };

  flake.modules.homeManager.default.imports = [hm.paseo];
}
