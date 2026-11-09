{ config, pkgs, ... }:
{
  # Nix manages the toolchain; rustup is not needed.
  home.packages = with pkgs; [ cargo rustc rustfmt clippy rust-analyzer ];

  home.sessionVariables = {
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
  };
  home.sessionPath = [ "${config.xdg.dataHome}/cargo/bin" ];
}
