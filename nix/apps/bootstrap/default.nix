# Install one of this flake's hosts onto this machine from a NixOS live USB.
#   nix run github:trent-maetzold/dotfiles#bootstrap -- muninn
{
  pkgs,
  app,
  self,
}: let
  inherit (pkgs) lib;

  path = lib.makeBinPath (with pkgs; [efibootmgr nixos-install-tools]);

  # Each host's userborn unit as a shell command, run by hand in the chroot.
  # Its store paths are used only inside /mnt, where nixos-install puts them,
  # so the app itself needn't depend on them.
  userbornCommands = builtins.mapAttrs (host: system: let
    service = system.config.systemd.services.userborn;
  in
    builtins.unsafeDiscardStringContext
    "env ${lib.escapeShellArgs (lib.mapAttrsToList (name: value: "${name}=${value}") service.environment)} ${service.serviceConfig.ExecStart}")
  self.nixosConfigurations;

  script =
    builtins.replaceStrings ["@path@" "@flake@" "@userborn@"] [path "${self}" (builtins.toJSON userbornCommands)]
    (builtins.readFile ./bootstrap.nu);
in
  app "Install a host from this flake onto this machine (live USB)"
  (lib.getExe (pkgs.writers.writeNuBin "bootstrap" script))
