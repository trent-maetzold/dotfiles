# Install one of this flake's hosts onto this machine, or a remote one over SSH.
#   nix run github:trent-maetzold/dotfiles#bootstrap -- muninn
#   nix run github:trent-maetzold/dotfiles#bootstrap -- muninn 192.168.1.50
{
  pkgs,
  app,
  self,
}: let
  inherit (pkgs) lib;

  # Put on PATH by the script itself (not a wrapper), so they survive sudo.
  path = lib.makeBinPath (with pkgs; [
    disko
    efibootmgr
    mkpasswd
    netcat
    nixos-anywhere
    openssh
  ]);

  # The LUKS passwordFiles disko encrypts with, under a disk's content.
  luksPasswordFiles = content:
    if content.type == "luks"
    then [content.passwordFile] ++ luksPasswordFiles content.content
    else if content.type == "gpt"
    then lib.concatMap (partition: luksPasswordFiles partition.content) (lib.attrValues content.partitions)
    else [];

  # What the script needs from each host, read from its config at build time.
  hostInfo = _: nixos: let
    inherit (nixos) config;
    disks = lib.attrValues config.disko.devices.disk;
  in {
    disks = map (disk: {inherit (disk) name device;}) disks;
    diskPasswordFiles = lib.remove null (lib.concatMap (disk: luksPasswordFiles disk.content) disks);
    userPasswordFiles =
      lib.mapAttrsToList (name: user: {
        inherit name;
        file = user.hashedPasswordFile;
      })
      (lib.filterAttrs (_: user: user.hashedPasswordFile != null) config.users.users);
  };

  hosts = lib.mapAttrs hostInfo self.nixosConfigurations;

  # The script installs from the exact copy of this flake it was built from.
  script =
    builtins.replaceStrings ["@path@" "@flake@" "@hosts@"] [path "${self}" (builtins.toJSON hosts)]
    (builtins.readFile ./bootstrap.nu);
in
  app "Install a host from this flake here, or on a remote machine with nixos-anywhere"
  (lib.getExe (pkgs.writers.writeNuBin "bootstrap" script))
