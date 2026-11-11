# Install one of this flake's hosts onto this machine from a NixOS live USB.
#   nix run github:trent-maetzold/dotfiles#bootstrap -- muninn
{
  pkgs,
  app,
  self,
}: let
  path = pkgs.lib.makeBinPath (with pkgs; [efibootmgr nixos-install-tools]);

  script =
    builtins.replaceStrings ["@path@" "@flake@"] [path "${self}"]
    (builtins.readFile ./bootstrap.nu);
in
  app "Install a host from this flake onto this machine (live USB)"
  (pkgs.lib.getExe (pkgs.writers.writeNuBin "bootstrap" script))
