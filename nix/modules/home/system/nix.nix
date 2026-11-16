# Nix administration: nh for switching (its flake defaults to the host flake at
# ~/.config/nixos; hosts built from this repo point it here), comma to run
# anything via nix-index, nix-search-tv to find packages, and nom, nvd,
# nix-tree and nix-diff for inspecting builds.
{
  config,
  lib,
  nix-index-database,
  pkgs,
  ...
}: {
  imports = [nix-index-database.homeModules.nix-index];

  programs.nh = {
    enable = true;
    flake = lib.mkDefault "${config.home.homeDirectory}/.config/nixos";
  };
  programs.nix-index-database.comma.enable = true;
  programs.nix-search-tv.enable = true;

  home.packages = with pkgs; [
    nix-output-monitor
    nvd # diff two system builds
    nix-tree
    nix-diff
  ];
}
