# Writing Nix: nix-init/nurl/nix-update for packages, statix/deadnix for
# linting. LSPs and formatters come from Mason. Admin tools: system/nix.nix.
{pkgs, ...}: {
  programs.nix-init.enable = true;

  home.packages = with pkgs; [nurl nix-update statix deadnix];
}
