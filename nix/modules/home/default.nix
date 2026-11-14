{
  config,
  lib,
  pkgs,
  ...
}: {
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

  home.packages = with pkgs; [
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
  ];
}
