# Hermes Desktop, pinned to the k3s gateway. The launcher sets
# HERMES_DESKTOP_REMOTE_URL, so the desktop never starts a local backend:
# every session runs against the Hermes Deployment on Niðavellir.
#
# The token stays out of the Nix store. `extraRun` reads it at start time
# from a file only the user can read; copy it from the hermes-secrets
# Secret (HERMES_DASHBOARD_SESSION_TOKEN) on the cluster.
{
  config,
  hermes-agent,
  pkgs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  tokenFile = "${config.xdg.configHome}/hermes/remote-token";
  remoteUrl = "https://dash.hermes.ts.trkm.io";
in {
  home.packages = [
    (hermes-agent.packages.${system}.desktop.override {
      extraEnv.HERMES_DESKTOP_REMOTE_URL = remoteUrl;
      extraRun = [
        ''
          if [ -r ${tokenFile} ]; then
            HERMES_DESKTOP_REMOTE_TOKEN="$(tr -d '\r\n' < ${tokenFile})"
            export HERMES_DESKTOP_REMOTE_TOKEN
          else
            echo "hermes-desktop: no gateway token at ${tokenFile}." >&2
            echo "hermes-desktop: copy HERMES_DASHBOARD_SESSION_TOKEN from the hermes-secrets Secret into that file (chmod 600)." >&2
            echo "hermes-desktop: refusing to start a local backend." >&2
            exit 1
          fi
        ''
      ];
    })
  ];
}
