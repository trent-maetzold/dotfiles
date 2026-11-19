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

  # Prefer the Nix server over rustup's proxy without changing the shell toolchain.
  programs.neovim.extraWrapperArgs = ["--prefix" "PATH" ":" "${pkgs.rust-analyzer}/bin"];
  home.packages = [pkgs.rustup];
  home.sessionPath = ["${config.programs.cargo.cargoHome}/bin"];
}
