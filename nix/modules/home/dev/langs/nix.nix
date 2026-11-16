# Nix tools: nh (switch/clean; hosts set its flake), comma (run anything via
# nix-index), nix-init/nurl for new packages, nix-tree/nix-diff/nom for
# inspecting builds, statix/deadnix for linting. LSPs come from Mason.
{
  pkgs,
  nix-index-database,
  ...
}: {
  imports = [nix-index-database.homeModules.nix-index];

  programs.nix-index-database.comma.enable = true;
  programs.nix-search-tv.enable = true;
  programs.nix-init.enable = true;
  programs.nh.enable = true;

  home.packages = with pkgs; [nurl nix-update nix-tree nix-diff nix-output-monitor statix deadnix];
}
