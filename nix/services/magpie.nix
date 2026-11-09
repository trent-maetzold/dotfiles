{inputs, ...}: {
  # magpie gateway + web UI. Gets only its own state dir and pi's config dir
  # (it writes pi's models/extensions there).
  flake.homeModules.magpie = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.dotfiles.magpie;
    home = config.home.homeDirectory;
  in {
    imports = [inputs.quadlet-nix.homeManagerModules.quadlet];

    options.dotfiles.magpie = {
      enable = lib.mkEnableOption "magpie in a rootless podman container";
      port = lib.mkOption {
        type = lib.types.port;
        default = 3425;
        description = "Host loopback port. Stop the host magpie app first if it holds this port.";
      };
      stateDir = lib.mkOption {
        type = lib.types.str;
        default = "${home}/.local/share/magpie-container";
      };
      piDir = lib.mkOption {
        type = lib.types.str;
        default = "${home}/.pi/agent";
      };
    };

    config = lib.mkIf cfg.enable {
      virtualisation.quadlet.autoUpdate.enable = true;
      virtualisation.quadlet.containers.magpie = {
        autoStart = true;
        serviceConfig = {
          Restart = "always";
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${cfg.stateDir} ${cfg.piDir}";
        };
        containerConfig = {
          image = "ghcr.io/yetone/magpie:latest";
          autoUpdate = "registry";
          # Image runs as uid 65532 with HOME=/config/home: map our uid onto it so the bind mounts are writable.
          userns = "keep-id:uid=65532,gid=65532";
          volumes = [
            "${cfg.stateDir}:/config"
            "${cfg.piDir}:/config/home/.pi/agent"
          ];
          publishPorts = ["127.0.0.1:${toString cfg.port}:3425"];
        };
      };
    };
  };
}
