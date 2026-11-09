{config, ...}: let
  hm = config.flake.modules.homeManager;
in {
  # Changes constantly (LazyVim writes lazy-lock.json): out-of-store symlink.
  flake.modules.homeManager.nvim = {
    config,
    pkgs,
    ...
  }: {
    home.packages = [pkgs.neovim];
    xdg.configFile.nvim.source = config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.path}/config/nvim";
  };

  flake.modules.homeManager.default.imports = [hm.nvim];
}
