{
  config,
  pkgs,
  ...
}: {
  # Nix manages the toolchain; rustup is not needed.
  programs.cargo = {
    enable = true;
    cargoHome = "${config.xdg.dataHome}/cargo";
  };

  home.packages = with pkgs; [rustc rustfmt clippy rust-analyzer];
  home.sessionPath = ["${config.programs.cargo.cargoHome}/bin"];
}
