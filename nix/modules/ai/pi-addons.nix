# Configs for pi addons that live outside ~/.pi/agent. Addons that read
# ~/.pi/agent/<name>.json (caveman, btw, pi-pretty, plannotator) are already
# covered by the ~/.pi link; see config/pi/agent/.gitignore.
# Files only: both dirs also hold logs and state.
{ config, ... }:
let
  link = path: config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.config/dotfiles/config/${path}";
in
{
  xdg.configFile."ponytail/config.json".source = link "ponytail/config.json";
  home.file.".pi-lens/config.json".source = link "pi-lens/config.json";
}
