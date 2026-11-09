{ config, pkgs, ... }:
{
  home.packages = [ pkgs.pi-coding-agent ];

  home.file.".pi".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.config/dotfiles/config/pi";
}
