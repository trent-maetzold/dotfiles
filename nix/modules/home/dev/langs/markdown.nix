{pkgs, ...}: {
  home.packages = with pkgs; [markdownlint-cli2 markdown-toc];
  programs.neovim.extraPackages = [pkgs.marksman];
}
