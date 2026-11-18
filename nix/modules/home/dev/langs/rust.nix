{
  config,
  pkgs,
  ...
}: {
  programs.cargo = {
    enable = true;
    package = null;
    cargoHome = "${config.xdg.dataHome}/cargo";
  };

  home.packages = [pkgs.rustup];
  home.sessionPath = ["${config.programs.cargo.cargoHome}/bin"];
}
