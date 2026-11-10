{
  config,
  lib,
  pkgs,
  ...
}: let
  noProxy = config.home.sessionVariables.NO_PROXY or null;
  context = pkgs.writeTextDir "Containerfile" ''
    FROM docker.io/library/archlinux:latest
    ENV UV_SYSTEM_CERTS=true${lib.optionalString (noProxy != null) " NO_PROXY=${noProxy} no_proxy=${noProxy}"}
    RUN install -m 644 /run/host-ca.pem /etc/ca-certificates/trust-source/anchors/nixos-host.pem \
        && update-ca-trust \
        && pacman -Syu --noconfirm --needed base-devel postgresql-libs krb5 git uv \
        && pacman -Scc --noconfirm
  '';
in {
  # Provider for `podman compose`, found on PATH.
  home.packages = with pkgs; [podman-compose lazydocker];

  services.podman = {
    enable = true;
    autoUpdate.enable = false;
    builds.arch-build = {
      autoStart = false;
      file = "${context}/Containerfile";
      workingDirectory = "${context}";
      extraPodmanArgs = [
        # Standard host CA bundle path (NixOS and most distros); no osConfig so non-NixOS hosts work.
        "--volume=/etc/ssl/certs/ca-certificates.crt:/run/host-ca.pem:ro"
      ];
      # WSL has no host network-online target for Quadlet's user wait helper.
      extraConfig.Quadlet.DefaultDependencies = false;
      extraConfig.Service.TimeoutStartSec = "20min";
    };
  };
}
