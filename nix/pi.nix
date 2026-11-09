{config, ...}: let
  hm = config.flake.modules.homeManager;
in {
  # pi stays at ~/.pi/agent (many addons hardcode it): an out-of-store symlink
  # to config/pi in this checkout, where secrets and state are gitignored.
  # Containers mount the real path.
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

    config.home.file.".pi/agent".source = config.lib.file.mkOutOfStoreSymlink config.dotfiles.pi.dir;
  };

  flake.modules.homeManager.default.imports = [hm.pi];
}
