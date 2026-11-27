# Hermes Desktop, pinned to the k3s gateway. The launcher sets
# HERMES_DESKTOP_REMOTE_URL, so the desktop never starts a local backend:
# every session runs against the Hermes Deployment on Niðavellir.
#
# The token stays out of the Nix store and off disk: muninn's sops secret
# `hermes-desktop-token` decrypts into /run/secrets at boot, and `extraRun`
# reads it at start time.
{
  hermes-agent,
  pkgs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  # Decrypted from sops on muninn; the file lives on tmpfs, never in $HOME.
  tokenFile = "/run/secrets/hermes-desktop-token";
  remoteUrl = "https://hermes.ts.trkm.io";
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
            echo "hermes-desktop: muninn decrypts it from sops to this path at boot." >&2
            echo "hermes-desktop: refusing to start a local backend." >&2
            exit 1
          fi
        ''
      ];
    })
  ];
}
