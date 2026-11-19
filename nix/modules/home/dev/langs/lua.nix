{pkgs, ...}: {
  home.packages = [pkgs.stylua];
  programs.neovim.extraPackages = [pkgs.lua-language-server];
}
