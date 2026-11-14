{
  config,
  pkgs,
  ...
}: {
  programs.neovim = {
    enable = true;
    # LazyVim owns ~/.config/nvim/init.lua (linked below).
    sideloadInitLua = true;
  };

  # Keep LazyVim writable and versioned in this checkout.
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.config/dotfiles/config/nvim";
}
