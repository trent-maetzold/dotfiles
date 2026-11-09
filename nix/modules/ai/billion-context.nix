{ pkgs, ... }:
let
  billion-context = pkgs.callPackage ../../pkgs/billion-context { };

  # ~/.config/billion-context/billion-context.json
  # Keys: CONFIGURATION.md in the package. Env vars override these.
  # The file is read-only (Nix store), so the web UI cannot save changes.
  settings = {
    providers = { };

    # The self-updater and advisory watcher `npm install -g` over the
    # running copy; the store is read-only, so updates go through Nix.
    autoUpdate = false;
    advisoryCheck = false;

    # pi.subagents = false; # drop acp_delegate* tools, keep compression
  };
in
{
  home.packages = [ billion-context ];

  xdg.configFile."billion-context/billion-context.json" = {
    text = builtins.toJSON settings;
    force = true; # replace the default file bili created on first run
  };

  # Stable path referenced from config/pi/agent/settings.json "packages".
  xdg.dataFile."pi/packages/billion-context".source =
    "${billion-context}/lib/node_modules/billion-context";
}
