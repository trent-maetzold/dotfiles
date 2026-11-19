{pkgs, ...}: {
  home.packages = with pkgs; [dotnetCorePackages.sdk_10_0 csharpier fantomas];
  programs.neovim.extraPackages = with pkgs; [fsautocomplete omnisharp-roslyn];
}
