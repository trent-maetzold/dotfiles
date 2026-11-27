{
  flake.modules.homeManager.nix =
    # Nix administration: nh for switching from dotfiles main,
    # comma to run anything via nix-index, nix-search-tv to find packages, and
    # nom, nvd, nix-tree and nix-diff for inspecting builds.
    {
      nix-index-database,
      pkgs,
      ...
    }: {
      imports = [nix-index-database.homeModules.nix-index];

      programs.nh = {
        enable = true;
        flake = "github:trent-maetzold/dotfiles/main";
      };
      programs.nix-index-database.comma.enable = true;
      programs.nix-search-tv.enable = true;

      home.packages = with pkgs; [
        nix-output-monitor
        nvd # diff two system builds
        nix-tree
        nix-diff
      ];
    };
}
