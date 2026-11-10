{
  config,
  lib,
  pkgs,
  ...
}: let
  # gcx (Grafana) runs with its token read from a sops secret at launch, so it
  # reaches only that process. Installed only when the host declares the secret
  # (sops.secrets.GRAFANA_SERVICE_ACCOUNT_TOKEN); set GRAFANA_SERVER there too.
  grafana =
    lib.optional (config.sops.secrets ? GRAFANA_SERVICE_ACCOUNT_TOKEN)
    (pkgs.withSecrets pkgs.gcx {GRAFANA_TOKEN = config.sops.secrets.GRAFANA_SERVICE_ACCOUNT_TOKEN.path;});
in {
  home.preferXdgDirectories = true;
  home.sessionPath = ["${config.home.homeDirectory}/.local/bin"];

  home.sessionVariables = {
    SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    SSL_CERT_DIR = "/etc/ssl/certs";
    CURL_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
    GIT_SSL_CAINFO = "/etc/ssl/certs/ca-certificates.crt";
    NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt";
  };

  systemd.user.startServices = "sd-switch";

  home.packages = with pkgs;
    [
      # Search and navigation
      ripgrep
      fd
      fzf
      tree-sitter

      # Build toolchain for native dependencies
      gcc
      gnumake
      pkg-config

      # General utilities
      curl
      unzip
      just

      # Docs lookup for agents
      ctx7 # Context7: current library docs
      deepwiki-cli # DeepWiki docs for public GitHub repos
    ]
    ++ grafana;
}
