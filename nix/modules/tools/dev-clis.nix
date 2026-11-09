# Jira, Bitbucket, and docs CLIs. Tokens come from sops (see
# ~/.config/nixos/nix/secrets.nix): JIRA_API_TOKEN and BKT_TOKEN.
{ pkgs, bkt, ... }:
{
  home.packages = [
    pkgs.jira-cli-go # jira; one-time `jira init` writes ~/.config/.jira/.config.yml
    bkt
    (pkgs.callPackage ../../pkgs/ctx7 { })
    (pkgs.callPackage ../../pkgs/deepwiki { })
  ];

  home.sessionVariables = {
    JIRA_AUTH_TYPE = "bearer"; # Data Center personal access token
    BKT_HOST = "https://example.com"; # DC; bearer auth by default without BKT_USERNAME
  };
}
