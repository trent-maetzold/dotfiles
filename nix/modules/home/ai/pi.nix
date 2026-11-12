# pi plus config dirs for pi addons, all linked in place so they stay writable.
# Addons that read ~/.pi/agent/<name>.json are covered by the ~/.pi link; the
# rest live under config/pi/packages/<name>, each with a .gitignore that keeps
# runtime state out.
#
# billion-context is a Nix package (bump nix/pkgs/billion-context); settings.json
# loads it from the path below. Keep its autoUpdate/advisoryCheck off.
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
  xdg.dataFile."pi/packages/billion-context".source = pkgs.billion-context;
  xdg.configFile."ponytail".source = link "/packages/ponytail";
}
