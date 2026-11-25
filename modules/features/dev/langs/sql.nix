{flake.modules.homeManager.dev-langs-sql = {pkgs, ...}: {
  home.packages = [pkgs.sqlfluff];
};}
