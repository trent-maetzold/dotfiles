{
  config,
  inputs,
  ...
}: let
  hm = config.flake.modules.homeManager;
in {
  # Rootless podman and quadlet entirely from nix: nothing from the host
  # (only newuidmap/newgidmap and /etc/subuid, which any desktop has).
  # magpie and paseo rely on this; it is in `default` once, not imported by them.
  flake.modules.homeManager.podman = {
    config,
    pkgs,
    ...
  }: {
    imports = [inputs.quadlet-nix.homeManagerModules.quadlet];

    # podman, policy.json and containers.conf.
    services.podman.enable = true;
    services.podman.autoUpdate.enable = false; # quadlet-nix defines the same timer
    virtualisation.quadlet.autoUpdate.enable = true;

    # quadlet units only exist if systemd runs podman's generator; link it
    # where systemd looks for user generators.
    xdg.configFile."systemd/user-generators/podman-user-generator".source = "${config.services.podman.package}/lib/systemd/user-generators/podman-user-generator";
  };

  flake.modules.homeManager.default.imports = [hm.podman];
}
