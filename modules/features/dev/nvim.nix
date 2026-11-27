{
  flake.modules.homeManager.neovim = {pkgs, ...}: {
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
      # LazyVim owns ~/.config/nvim/init.lua (linked by the dotfiles module).
      sideloadInitLua = true;
    };

    home.packages = [pkgs.lua51Packages.luarocks];
  };
}
