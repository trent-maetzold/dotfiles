{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.cargo = {
    enable = true;
    cargoHome = "${config.xdg.dataHome}/cargo";
  };

  # Keep the Nix toolchain on PATH; use rustup run for alternate toolchains.
  home.packages = with pkgs; [rustc rustfmt clippy rust-analyzer (lib.setPrio 20 rustup)];
  home.sessionPath = ["${config.programs.cargo.cargoHome}/bin"];
}
