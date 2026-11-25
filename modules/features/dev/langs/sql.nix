{
  flake.modules.homeManager.sql = {pkgs, ...}: {
    home.packages = [pkgs.sqlfluff];
  };
}
