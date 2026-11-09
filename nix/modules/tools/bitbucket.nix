# bkt (Bitbucket CLI). Set BKT_HOST to the server; with a token and no
# BKT_USERNAME, Data Center uses bearer auth.
{ config, pkgs, bkt, ... }:
let
  withSecrets = pkgs.callPackage ../../pkgs/with-secrets.nix { };
in
{
  sops.secrets.bitbucket-token.key = "integrations/bitbucket/token";

  home.packages = [
    (withSecrets bkt { BKT_TOKEN = config.sops.secrets.bitbucket-token.path; })
  ];
}
