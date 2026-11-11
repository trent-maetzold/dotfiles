# Install one of this flake's hosts onto this machine, or a remote one over SSH.
#   nix run github:trent-maetzold/dotfiles#bootstrap -- muninn
#   nix run github:trent-maetzold/dotfiles#bootstrap -- muninn 192.168.1.50
{
  pkgs,
  app,
  self,
}: let
  # Put on PATH by the script itself (not a wrapper), so they survive sudo.
  path = pkgs.lib.makeBinPath (with pkgs; [
    netcat
    nixos-anywhere
    nixos-install-tools
    util-linux
  ]);

  # The script installs from the exact copy of this flake it was built from.
  script =
    builtins.replaceStrings ["@path@" "@flake@"] [path "${self}"]
    (builtins.readFile ./bootstrap.nu);
in
  app "Install a host from this flake here, or on a remote machine with nixos-anywhere"
  (pkgs.lib.getExe (pkgs.writers.writeNuBin "bootstrap" script))
