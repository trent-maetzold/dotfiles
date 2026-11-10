{ config, lib, pkgs, user, bkt, ... }:
let
  # Work CLIs run with their token read from a sops secret at launch, so it
  # reaches only that process. Each is installed only when the host declares
  # the secret (sops.secrets.<NAME> in the system flake); otherwise skipped.
  withSecrets = import ../lib/with-secrets.nix pkgs;
  withSecret = secret: env: package:
    lib.optional (config.sops.secrets ? ${secret})
      (withSecrets package { ${env} = config.sops.secrets.${secret}.path; });

  # Set BKT_HOST; with a token and no BKT_USERNAME, Data Center uses bearer auth.
  bitbucket = withSecret "BITBUCKET_ACCESS_TOKEN" "BKT_TOKEN" bkt;
  # Set CONFLUENCE_HOST; without CONFLUENCE_EMAIL the token is sent as a bearer PAT.
  confluence = withSecret "CONFLUENCE_API_TOKEN" "CONFLUENCE_API_TOKEN" pkgs.confluence-cli;
  # Set GRAFANA_SERVER (and GRAFANA_ORG_ID on-prem).
  grafana = withSecret "GRAFANA_SERVICE_ACCOUNT_TOKEN" "GRAFANA_TOKEN" pkgs.gcx;
  # One-time `jira init` writes ~/.config/.jira/.config.yml.
  jira = withSecret "JIRA_API_TOKEN" "JIRA_API_TOKEN" pkgs.jira-cli-go;
in
{
  home.stateVersion = user.stateVersion;
  home.preferXdgDirectories = true;
  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  home.sessionVariables = {
    SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    SSL_CERT_DIR = "/etc/ssl/certs";
    CURL_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
    GIT_SSL_CAINFO = "/etc/ssl/certs/ca-certificates.crt";
    NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt";
  };

  systemd.user.startServices = "sd-switch";

  home.packages = bitbucket ++ confluence ++ grafana ++ jira ++ (with pkgs; [
    # Common tools used by the editor, agents, and native dependencies.
    just
    ripgrep
    fd
    fzf
    tree-sitter
    unzip
    curl
    gcc
    gnumake
    pkg-config
    ctx7 # Context7: current library docs for agents
    deepwiki-cli # DeepWiki docs for public GitHub repos

    outlook-cli # `outlook`: Windows Outlook (classic), generated from its MCP server
  ]);
}
