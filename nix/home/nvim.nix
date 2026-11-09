{
  # Changes constantly (LazyVim writes lazy-lock.json): out-of-store symlink.
  flake.homeModules.nvim = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.dotfiles.nvim.enable = lib.mkEnableOption "neovim with the config/nvim checkout symlinked";

    config = lib.mkIf config.dotfiles.nvim.enable {
      home.packages = [pkgs.neovim];
      xdg.configFile.nvim.source = config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.path}/config/nvim";
    };
  };
}
