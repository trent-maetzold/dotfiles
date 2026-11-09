{ config, pkgs, ... }:
{
  home.username = "<user>";
  home.homeDirectory = "/home/<user>";
  home.stateVersion = "26.11";
  home.preferXdgDirectories = true;
  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  home.sessionVariables = {
    SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    SSL_CERT_DIR = "/etc/ssl/certs";
    CURL_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
    GIT_SSL_CAINFO = "/etc/ssl/certs/ca-certificates.crt";
    NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt";
    NO_PROXY = "localhost,127.0.0.1,::1,.example.com";
    no_proxy = "localhost,127.0.0.1,::1,.example.com";
  };

  systemd.user.startServices = "sd-switch";

  home.packages = with pkgs; [

    # Common tools used by the editor, agents, and native dependencies.
    ripgrep
    fd
    fzf
    tree-sitter
    unzip
    curl
    gcc
    gnumake
    pkg-config
  ];
}
