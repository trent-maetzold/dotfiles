{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.cargo = {
    enable = true;
    package = null;
    cargoHome = "${config.xdg.dataHome}/cargo";
  };

  home.activation.initRustup = lib.hm.dag.entryAfter ["writeBoundary"] ''
    rustup=${lib.getExe pkgs.rustup}
    if ! "$rustup" default >/dev/null 2>&1; then
      run "$rustup" default stable
    fi
    if ! RUSTUP_AUTO_INSTALL=0 "$rustup" which rust-analyzer >/dev/null 2>&1; then
      run "$rustup" component add rust-analyzer
    fi
  '';
  home.packages = [pkgs.rustup];
  home.sessionPath = ["${config.programs.cargo.cargoHome}/bin"];
}
