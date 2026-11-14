{pkgs, ...}: {
  services.podman = {
    enable = true;
    autoUpdate.enable = false;
    settings.containers = {
      # extraPackages only reaches Podman machines (macOS); this is the Linux way.
      engine.compose_providers = ["${pkgs.podman-compose}/bin/podman-compose"];
      # Host CA bundle (incl. corporate roots) in every container, at the path
      # Debian/Alpine/Fedora-style images read.
      containers.volumes = ["/etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt:ro"];
    };
  };

  programs.lazydocker.enable = true;
}
