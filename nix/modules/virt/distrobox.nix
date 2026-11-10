{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.distrobox = {
    enable = true;
    enableSystemdUnit = false;
    settings.container_manager = "podman";
    containers.arch-build = {
      image = "localhost/homemanager/arch-build:latest";
      volume = ["/etc/ssl/certs/ca-certificates.crt:/etc/ca-certificates/extracted/tls-ca-bundle.pem:ro"];
      init = false;
      start_now = true;
      entry = false;
    };
  };

  home.activation.recreateArchBuild = lib.hm.dag.entryAfter ["reloadSystemd"] ''
    # Rebuild/recreate when the image definition changes.
    # ${config.services.podman.builds.arch-build.file}
    run ${pkgs.systemd}/bin/systemctl --user restart podman-arch-build-build.service
    run ${pkgs.coreutils}/bin/env PATH="${lib.makeBinPath [config.services.podman.package pkgs.gawk]}:/run/current-system/sw/bin:$PATH" \
      ${pkgs.distrobox}/bin/distrobox-assemble create --replace --name arch-build \
      --file ${lib.escapeShellArg "${config.xdg.configHome}/distrobox/containers.ini"}
  '';

  home.shellAliases.bx = "distrobox enter --name arch-build --";
}
