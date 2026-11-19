{
  config,
  pkgs,
  ...
}: {
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      bash-language-server
      biome
      docker-compose-language-service
      dockerfile-language-server
      fsautocomplete
      lua-language-server
      marksman
      nil
      taplo
      vscode-langservers-extracted # JSON and ESLint
      yaml-language-server
    ];
    # Prefer the Nix server over rustup's proxy without changing the shell toolchain.
    extraWrapperArgs = ["--prefix" "PATH" ":" "${pkgs.rust-analyzer}/bin"];
    # LazyVim owns ~/.config/nvim/init.lua (linked below).
    sideloadInitLua = true;
  };

  home.packages = [pkgs.lua51Packages.luarocks];

  # Keep LazyVim writable and versioned in this checkout.
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.config/dotfiles/config/nvim";
}
