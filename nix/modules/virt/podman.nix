{ pkgs, osConfig, ... }:
let
  context = pkgs.writeTextDir "Containerfile" ''
    FROM docker.io/library/archlinux:latest
    ENV UV_SYSTEM_CERTS=true NO_PROXY=.example.com no_proxy=.example.com
    RUN install -m 644 /run/host-ca.pem /etc/ca-certificates/trust-source/anchors/nixos-host.pem \
        && update-ca-trust \
        && pacman -Syu --noconfirm --needed base-devel postgresql-libs krb5 git uv \
        && pacman -Scc --noconfirm
  '';
in
{
  # Provider for `podman compose`, found on PATH.
  home.packages = [ pkgs.podman-compose ];

  services.podman = {
    enable = true;
    autoUpdate.enable = false;
    builds.arch-build = {
      autoStart = false;
      file = "${context}/Containerfile";
      workingDirectory = "${context}";
      extraPodmanArgs = [
        "--volume=${osConfig.security.pki.caBundle}:/run/host-ca.pem:ro"
      ];
      # WSL has no host network-online target for Quadlet's user wait helper.
      extraConfig.Quadlet.DefaultDependencies = false;
      extraConfig.Service.TimeoutStartSec = "20min";
    };
  };
}
