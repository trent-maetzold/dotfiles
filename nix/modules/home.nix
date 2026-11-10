{
  config,
  lib,
  pkgs,
  sops-nix,
  ...
}: let
  # gcx (Grafana) runs with its token read from a sops secret at launch, so it
  # reaches only that process. Installed only when the host declares the secret
  # (sops.secrets.GRAFANA_SERVICE_ACCOUNT_TOKEN); set GRAFANA_SERVER there too.
  grafana =
    lib.optional (config.sops.secrets ? GRAFANA_SERVICE_ACCOUNT_TOKEN)
    (pkgs.withSecrets pkgs.gcx {GRAFANA_TOKEN = config.sops.secrets.GRAFANA_SERVICE_ACCOUNT_TOKEN.path;});
in {
  # config.sops.secrets are declared by the host flake.
  imports = [sops-nix.homeManagerModules.sops];

  home.preferXdgDirectories = true;
  home.shellAliases.dot = "nvim ${config.home.homeDirectory}/.config/dotfiles";
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

  # Search and navigation
  programs.ripgrep.enable = true;
  programs.fd.enable = true;
  programs.fzf.enable = true;
  # Native dependencies
  programs.gcc.enable = true;

  home.packages = with pkgs;
    [
      tree-sitter

      # Build toolchain for native dependencies
      gnumake
      pkg-config

      # General utilities
      curl
      unzip
      just # programs.just is deprecated upstream

      # Docs lookup for agents
      ctx7 # Context7: current library docs
      deepwiki-cli # DeepWiki docs for public GitHub repos
    ]
    ++ grafana;
}
