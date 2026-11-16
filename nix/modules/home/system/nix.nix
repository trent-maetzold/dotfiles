# Nix administration: nh for switching (this repo, at ~/.config/dotfiles),
# comma to run anything via nix-index, nix-search-tv to find packages, and
# nom, nvd, nix-tree and nix-diff for inspecting builds.
{
  config,
  nix-index-database,
  pkgs,
  ...
}: {
  imports = [nix-index-database.homeModules.nix-index];

  programs.nh = {
    enable = true;
    flake = "${config.home.homeDirectory}/.config/dotfiles";
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
