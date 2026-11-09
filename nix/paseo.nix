{
  config,
  inputs,
  ...
}: let
  hm = config.flake.modules.homeManager;
in {
  # paseo daemon running pi (via pi-acp), in a container built by nix. Gets its
  # own volume, pi's config dir and one workspace dir; nothing else from the host.
  flake.modules.homeManager.paseo = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dotfiles.paseo;
    volume = config.virtualisation.quadlet.volumes.paseo.ref;
    agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

    image = pkgs.dockerTools.buildLayeredImage {
      name = "paseo";
      tag = "latest";
      contents = [agents.paseo agents.pi agents.pi-acp pkgs.bashInteractive pkgs.coreutils pkgs.git pkgs.cacert pkgs.dockerTools.binSh pkgs.dockerTools.usrBinEnv];
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
        ];
        WorkingDir = "/workspace";
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
  in {
    options.dotfiles.paseo = {
      port = lib.mkOption {
        type = lib.types.port;
        default = 6767;
        description = "Host loopback port.";
      };
      workspace = lib.mkOption {
        type = lib.types.str;
        default = "${config.home.homeDirectory}/Work/agents";
        description = "The only project dir the agents can see.";
      };
    };

    config.virtualisation.quadlet = {
      volumes.paseo = {};
      containers.paseo = {
        autoStart = true;
        serviceConfig = {
          Restart = "always";
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${cfg.workspace}";
        };
        containerConfig = {
          image = "docker-archive:${image}";
          userns = "keep-id";
          volumes = [
            "${volume}:/home/agent/.paseo:U"
            "${paseoConfig}:/home/agent/.paseo/config.json:ro"
            "${config.dotfiles.pi.dir}:/home/agent/.pi/agent"
            "${cfg.workspace}:/workspace"
          ];
          publishPorts = ["127.0.0.1:${toString cfg.port}:6767"];
        };
      };
    };
  };

  flake.modules.homeManager.default.imports = [hm.paseo];
}
