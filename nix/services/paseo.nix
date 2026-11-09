{inputs, ...}: {
  # paseo daemon running pi (via pi-acp), in a container built by nix.
  # Gets only its own state, pi's config dir and one workspace dir.
  flake.homeModules.paseo = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dotfiles.paseo;
    home = config.home.homeDirectory;
    agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

    image = pkgs.dockerTools.buildLayeredImage {
      name = "paseo";
      tag = "latest";
      contents = [agents.paseo agents.pi agents.pi-acp pkgs.bashInteractive pkgs.coreutils pkgs.git pkgs.cacert pkgs.dockerTools.binSh pkgs.dockerTools.usrBinEnv];
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
    imports = [inputs.quadlet-nix.homeManagerModules.quadlet];

    options.dotfiles.paseo = {
      enable = lib.mkEnableOption "paseo + pi in a rootless podman container";
      port = lib.mkOption {
        type = lib.types.port;
        default = 6767;
        description = "Host loopback port.";
      };
      stateDir = lib.mkOption {
        type = lib.types.str;
        default = "${home}/.local/share/paseo-container";
      };
      piDir = lib.mkOption {
        type = lib.types.str;
        default = "${home}/.pi/agent";
      };
      workspace = lib.mkOption {
        type = lib.types.str;
        default = "${home}/Work/agents";
        description = "The only project dir the agents can see.";
      };
    };

    config = lib.mkIf cfg.enable {
      virtualisation.quadlet.containers.paseo = {
        autoStart = true;
        serviceConfig = {
          Restart = "always";
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${cfg.stateDir} ${cfg.piDir} ${cfg.workspace}";
        };
        containerConfig = {
          image = "docker-archive:${image}";
          userns = "keep-id";
          volumes = [
            "${cfg.stateDir}:/home/agent/.paseo"
            "${paseoConfig}:/home/agent/.paseo/config.json:ro"
            "${cfg.piDir}:/home/agent/.pi/agent"
            "${cfg.workspace}:/workspace"
          ];
          publishPorts = ["127.0.0.1:${toString cfg.port}:6767"];
        };
      };
    };
  };
}
