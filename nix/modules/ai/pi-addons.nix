# Config dirs for pi addons that live outside ~/.pi/agent. Addons that read
# ~/.pi/agent/<name>.json are covered by the ~/.pi link. State in these dirs
# is kept out of git by each dir's .gitignore.
{ config, ... }:
let
  link = path: config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.config/dotfiles/config/${path}";
in
{
  xdg.configFile."ponytail".source = link "ponytail";
  home.file.".pi-lens".source = link "pi-lens";
}
