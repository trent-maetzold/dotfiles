{pkgs, ...}: {
  home.packages = [
    (pkgs.rWrapper.override {packages = [pkgs.rPackages.languageserver];})
  ];
}
