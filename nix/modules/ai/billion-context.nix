{ config, pkgs, ... }:
let
  billion-context = pkgs.callPackage ../../pkgs/billion-context { };

  # bili's self-updater and advisory watcher try to `npm install -g` over
  # the running copy; the store is read-only, so updates go through Nix.
  env = {
    ACP_AUTO_UPDATE = "0";
    BILI_ADVISORY_CHECK = "0";
  };
in
{
  home.packages = [ billion-context ];

  home.sessionVariables = env;
  systemd.user.sessionVariables = env; # paseo and other user services

  # Stable path referenced from config/pi/agent/settings.json "packages".
  xdg.dataFile."pi/packages/billion-context".source =
    "${billion-context}/lib/node_modules/billion-context";
}
