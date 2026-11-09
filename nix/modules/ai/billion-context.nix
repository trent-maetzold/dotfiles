# billion-context is installed by pi ("npm:billion-context" in
# config/pi/agent/settings.json). Its config lives in this repo and is
# linked in place, so the bili web UI can still save changes.
#
# autoUpdate/advisoryCheck are off: pi updates the package
# (`pi update --extensions`); bili's updater would `npm install -g` a
# second, separate copy.
{ config, ... }:
{
  xdg.configFile."billion-context".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.config/dotfiles/config/billion-context";
}
