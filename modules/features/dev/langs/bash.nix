{flake.modules.homeManager.dev-langs-bash = {pkgs, ...}: {
  home.packages = [pkgs.shfmt];
  programs.neovim.extraPackages = [pkgs.bash-language-server];
};}
