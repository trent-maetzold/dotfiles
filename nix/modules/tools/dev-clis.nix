# Jira, Bitbucket, Confluence, Grafana, and docs CLIs. Tokens come from sops (see
# ~/.config/nixos/nix/secrets.nix): JIRA_API_TOKEN, BKT_TOKEN, GRAFANA_TOKEN,
# CONFLUENCE_API_TOKEN.
{ pkgs, bkt, ... }:
{
  home.packages = [
    pkgs.jira-cli-go # jira; one-time `jira init` writes ~/.config/.jira/.config.yml
    bkt
    pkgs.grafanactl
    (pkgs.callPackage ../../pkgs/confluence-cli { }) # confluence
    (pkgs.callPackage ../../pkgs/ctx7 { })
    (pkgs.callPackage ../../pkgs/deepwiki { })
  ];

  home.sessionVariables = {
    JIRA_AUTH_TYPE = "bearer"; # Data Center personal access token
    CONFLUENCE_HOST = "example.com"; # DC: /rest/api, bearer PAT without CONFLUENCE_EMAIL
    GRAFANA_SERVER = "https://example.com";
    GRAFANA_ORG_ID = "1"; # on-prem: no stack-id discovery
    BKT_HOST = "https://example.com"; # DC; bearer auth by default without BKT_USERNAME
  };
}
