# Rootless Podman as `docker`, with podman-compose and lazydocker.
{config, ...}: let
  modules.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      fuse-overlayfs
      podman-compose
      slirp4netns
      docker-compat
    ];

    programs = {
      lazydocker.enable = true;
      zsh.oh-my-zsh.plugins = ["podman"];
    };

    services.podman.enable = true;
  };
in {
  # Flake Modules
  flake.modules.homeManager.podman = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.podman];
}
