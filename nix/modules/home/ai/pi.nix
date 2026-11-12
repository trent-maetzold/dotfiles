# pi plus config dirs for pi addons, all linked in place so they stay writable.
# Addons that read ~/.pi/agent/<name>.json are covered by the ~/.pi link; the
# rest live under config/pi/packages/<name>, each with a .gitignore that keeps
# runtime state out.
#
# billion-context: autoUpdate/advisoryCheck are off because pi updates the
# package (`pi update --extensions`); bili's updater would `npm install -g` a
# second copy.
{
  config,
  pkgs,
  ...
}: let
  link = path:
    config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.config/dotfiles/config/pi${path}";
in {
  programs.pi-coding-agent.enable = true;

  home.file.".pi".source = link "";
  home.file.".pi-lens".source = link "/packages/pi-lens";
  xdg.configFile."billion-context".source = link "/packages/billion-context";
  xdg.configFile."ponytail".source = link "/packages/ponytail";

  # Mounted into the magpie container (ai/magpie.nix) so it finds this agent's sign-in.
  virtualisation.quadlet.containers.magpie.containerConfig.volumes = ["${config.home.homeDirectory}/.pi:/config/home/.pi"];
}
