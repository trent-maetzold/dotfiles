# Install one of this flake's hosts onto this machine from a NixOS live USB.
#   nix run github:trent-maetzold/dotfiles#bootstrap -- muninn
{
  pkgs,
  app,
  self,
}: let
  inherit (pkgs) lib;

  path = lib.makeBinPath (with pkgs; [efibootmgr mkpasswd nixos-install-tools util-linux]);

  # What bootstrap needs from each host: its disko disks, and its userborn unit
  # as a shell command to run by hand in the chroot. The command's store paths
  # are used only inside /mnt, where nixos-install puts them, so the app itself
  # needn't depend on them.
  hosts = builtins.mapAttrs (host: system: let
    inherit (system) config;
    service = config.systemd.services.userborn;
  in {
    disks = map (disk: disk.device) (builtins.attrValues config.disko.devices.disk);
    userborn =
      builtins.unsafeDiscardStringContext
      "env ${lib.escapeShellArgs (lib.mapAttrsToList (name: value: "${name}=${value}") service.environment)} ${service.serviceConfig.ExecStart}";
  })
  self.nixosConfigurations;

  script =
    builtins.replaceStrings ["@path@" "@flake@" "@hosts@"] [path "${self}" (builtins.toJSON hosts)]
    (builtins.readFile ./bootstrap.nu);
in
  app "Install a host from this flake onto this machine (live USB)"
  (lib.getExe (pkgs.writers.writeNuBin "bootstrap" script))
