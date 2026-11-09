{config, ...}: let
  hm = config.flake.modules.homeManager;
in {
  # magpie gateway + web UI. Gets its own volume and pi's config dir (it
  # writes pi's models and extensions there); nothing else from the host.
  flake.modules.homeManager.magpie = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.magpie;
    volume = config.virtualisation.quadlet.volumes.magpie.ref;
  in {
    options.dotfiles.magpie.port = lib.mkOption {
      type = lib.types.port;
      default = 3425;
      description = "Host loopback port. Stop the host magpie app first if it holds this port.";
    };

    config.virtualisation.quadlet = {
      volumes.magpie = {};
      containers.magpie = {
        autoStart = true;
        # shortcut: `:U` chowns the volume on start but loses a race with podman
        # creating the nested pi mountpoint, so a first start can fail once.
        # Restart=always makes the retry fix it; upgrade if that bites.
        serviceConfig.Restart = "always";
        containerConfig = {
          image = "ghcr.io/yetone/magpie:latest";
          autoUpdate = "registry";
          # Image runs as uid 65532 with HOME=/config/home.
          userns = "keep-id:uid=65532,gid=65532";
          volumes = [
            "${volume}:/config:U"
            "${config.dotfiles.pi.dir}:/config/home/.pi/agent"
          ];
          publishPorts = ["127.0.0.1:${toString cfg.port}:3425"];
        };
      };
    };
  };

  flake.modules.homeManager.default.imports = [hm.magpie];
}
