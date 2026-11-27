{
  flake.modules.homeManager.neovim = {
    config,
    pkgs,
    ...
  }: {
    programs.neovim = {
      enable = true;
      # Sets EDITOR and VISUAL in the Home Manager session environment.
      defaultEditor = true;
      extraPackages = with pkgs; [
        docker-compose-language-service
        dockerfile-language-server
        lua-language-server
        markdown-toc
        markdownlint-cli2
        marksman
        stylua
        taplo
        yaml-language-server
      ];
      # LazyVim owns ~/.config/nvim/init.lua (linked below).
      sideloadInitLua = true;
    };

    home.packages = [pkgs.lua51Packages.luarocks];

    # Keep LazyVim writable and versioned in this checkout.
    xdg.configFile."nvim".source =
      config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.config/dotfiles/config/nvim";
  };
}
