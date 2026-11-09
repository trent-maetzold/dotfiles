# billion-context is installed by pi ("npm:billion-context" in
# config/pi/agent/settings.json); this module only owns its config file.
{ ... }:
let
  # ~/.config/billion-context/billion-context.json
  # Keys: CONFIGURATION.md in the package. Env vars override these.
  # The file is read-only (Nix store), so the web UI cannot save changes.
  settings = {
    providers = { };

    # pi installs and updates the package (`pi update --extensions`).
    # bili's own updater would `npm install -g` a second, separate copy.
    autoUpdate = false;
    advisoryCheck = false;

    # pi.subagents = false; # drop acp_delegate* tools, keep compression
  };
in
{
  xdg.configFile."billion-context/billion-context.json" = {
    text = builtins.toJSON settings;
    force = true; # replace the default file bili created on first run
  };
}
