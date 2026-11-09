# confluence-cli. Set CONFLUENCE_HOST to the server; without CONFLUENCE_EMAIL
# a token is sent as a bearer PAT (Data Center).
{ pkgs, ... }:
{
  # shortcut: no token in sops yet, so no wrapper; declaring a missing sops key
  # fails every secret. Once integrations/confluence/token exists, wrap like jira.nix.
  home.packages = [ (pkgs.callPackage ../../pkgs/confluence-cli { }) ];
}
