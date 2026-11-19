{pkgs, ...}: {
  programs.neovim.extraPackages = with pkgs; [taplo yaml-language-server];
}
