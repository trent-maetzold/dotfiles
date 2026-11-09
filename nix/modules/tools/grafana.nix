# gcx (Grafana CLI). Set GRAFANA_SERVER (and GRAFANA_ORG_ID on-prem) to the
# server; the service account token comes from sops.
{ config, pkgs, ... }:
let
  withSecrets = pkgs.callPackage ../../pkgs/with-secrets.nix { };
in
{
  sops.secrets.grafana-token.key = "integrations/grafana/token";

  home.packages = [
    (withSecrets pkgs.gcx { GRAFANA_TOKEN = config.sops.secrets.grafana-token.path; })
  ];
}
