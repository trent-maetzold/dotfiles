# jira-cli. One-time `jira init` writes ~/.config/.jira/.config.yml (server,
# login, project); the API token comes from sops.
{ config, pkgs, ... }:
let
  withSecrets = pkgs.callPackage ../../pkgs/with-secrets.nix { };
in
{
  sops.secrets.jira-token.key = "integrations/jira/token";

  home.packages = [
    (withSecrets pkgs.jira-cli-go { JIRA_API_TOKEN = config.sops.secrets.jira-token.path; })
  ];
}
