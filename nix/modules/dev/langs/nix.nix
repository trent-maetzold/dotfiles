# Nix authoring: comma (run anything via nix-index), nix-init/nurl for new
# packages, nix-tree/nix-diff/nom for inspecting builds.
{
  pkgs,
  nix-index-database,
  ...
}: {
  imports = [nix-index-database.homeModules.nix-index];

  programs.nix-index-database.comma.enable = true;
  programs.nix-search-tv.enable = true;
  programs.nix-init.enable = true;

  home.packages = with pkgs; [nurl nix-update nix-tree nix-diff nix-output-monitor];
}
