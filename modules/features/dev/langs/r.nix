{flake.modules.homeManager.dev-langs-r = {pkgs, ...}: {
  home.packages = [
    (pkgs.rWrapper.override {packages = [pkgs.rPackages.languageserver];})
  ];
};}
