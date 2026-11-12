# Install nixosConfigurations.<host> from this flake onto this machine, booted
# from a NixOS live USB. disko asks before wiping and for the disk passphrase.
#
#   nix run github:trent-maetzold/dotfiles#bootstrap -- muninn
def main [host: string] {
  if (^id -u | into int) != 0 { exec sudo $env.CURRENT_FILE $host }
  $env.PATH = ("@path@" | split row ":") ++ $env.PATH
  $env.NIX_CONFIG = "experimental-features = nix-command flakes"
  let config = $"@flake@#nixosConfigurations.($host).config"
  let host_config = (r#'@hosts@'# | from json | get $host)

  # Firmware re-adds its built-in entries; nixos-install adds the new one.
  if (input "Remove all UEFI boot entries? [y/N] ") == "y" {
    for entry in (^efibootmgr | parse --regex '^Boot(?<number>[0-9A-F]{4})') {
      ^efibootmgr --quiet --bootnum $entry.number --delete-bootnum
    }
  }

  # disko skips mkfs on a new partition that already holds a filesystem, and its
  # wipe misses old ones where the new partitions start (an earlier install's
  # ESP, say). Discarding the disks between wipe and format leaves only zeros.
  ^nix run $"($config).system.build.destroy"
  for disk in $host_config.disks { ^blkdiscard --force $disk }
  ^nix run $"($config).system.build.formatMount"

  ^nixos-install --flake $"@flake@#($host)" --no-root-password

  # Enter the new system with the /etc overlay's persisted layer bind-mounted,
  # the way preservation does it at boot. Activation then mounts /etc on it,
  # userborn creates the users, and passwd sets trent's password.
  mkdir /mnt/persist/.rw-etc /mnt/.rw-etc
  ^mount --bind /mnt/persist/.rw-etc /mnt/.rw-etc

  print "Login password for trent:"
  ^nixos-enter --root /mnt -c $"export PATH=/run/current-system/sw/bin; ($host_config.userborn) && until passwd trent; do :; done"
}
