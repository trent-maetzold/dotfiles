{ config, ... }:
{
  home.file.".agents".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/config/agents";
}
