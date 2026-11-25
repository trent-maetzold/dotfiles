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
    for entry in (^efibootmgr | lines | parse --regex '^Boot(?<number>[0-9A-F]{4})') {
      ^efibootmgr --quiet --bootnum $entry.number --delete-bootnum
    }
  }

  # disko skips mkfs on a new partition that already holds a filesystem, and its
  # wipe misses old ones where the new partitions start (an earlier install's
  # ESP, say). Discarding the disks between wipe and format leaves only zeros.
  ^nix run $"($config).system.build.destroy"
  for disk in $host_config.disks { ^blkdiscard --force $disk }
  let password_hash = (ask-password-hash trent)
  ^nix run $"($config).system.build.formatMount"

  ^nixos-install --flake $"@flake@#($host)" --no-root-password

  # Enter the new system with the /etc overlay's persisted layer bind-mounted,
  # the way preservation does it at boot. Activation then mounts /etc on it,
  # userborn creates the users, and chpasswd sets trent's password.
  mkdir /mnt/persist/.rw-etc /mnt/.rw-etc
  ^mount --bind /mnt/persist/.rw-etc /mnt/.rw-etc
  $"trent:($password_hash)" | ^nixos-enter --root /mnt -c $"export PATH=/run/current-system/sw/bin; ($host_config.userborn) && chpasswd --encrypted"
}

# Ask for a user's password until it's typed the same twice; return its hash.
def ask-password-hash [user: string] {
  loop {
    let password = (input --suppress-output $"Enter password for ($user): ")
    let again = (input --suppress-output $"Enter password for ($user) again to be safe: ")
    if $password != "" and $password == $again {
      return ($password | ^mkpasswd --method=yescrypt --stdin)
    }
    print "Passwords did not match, please try again."
  }
}
