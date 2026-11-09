{ config, pkgs, ... }:
{
  home.packages = [ pkgs.neovim ];

  # Keep LazyVim writable and versioned in this checkout.
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.config/dotfiles/config/nvim";
}
