{config, ...}: let
  hm = config.flake.modules.homeManager;
in {
  # pi's config dir lives at ~/.config/pi, an out-of-store symlink to
  # config/pi in this checkout (secrets and state are gitignored there).
  # Containers mount the real path, not the symlink.
  flake.modules.homeManager.pi = {
    config,
    lib,
    ...
  }: {
    options.dotfiles.pi.dir = lib.mkOption {
      type = lib.types.str;
      default = "${config.dotfiles.path}/config/pi";
      readOnly = true;
      description = "Real path of pi's config dir, for container bind mounts.";
    };

    config = {
      xdg.configFile.pi.source = config.lib.file.mkOutOfStoreSymlink config.dotfiles.pi.dir;
      home.sessionVariables.PI_CODING_AGENT_DIR = "${config.xdg.configHome}/pi";
      systemd.user.sessionVariables.PI_CODING_AGENT_DIR = "${config.xdg.configHome}/pi";
    };
  };

  flake.modules.homeManager.default.imports = [hm.pi];
}
