{
  flake.modules.homeManager.bash = {pkgs, ...}: {
    home.packages = [pkgs.shfmt];
    programs.neovim.extraPackages = [pkgs.bash-language-server];
  };
}
