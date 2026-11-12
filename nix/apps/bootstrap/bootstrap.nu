# Install nixosConfigurations.<host> from this flake onto this machine, booted
# from a NixOS live USB. disko asks before wiping and for the disk passphrase.
#
#   nix run github:trent-maetzold/dotfiles#bootstrap -- muninn
def main [host: string] {
  if (^id -u | into int) != 0 { exec sudo $env.CURRENT_FILE $host }
  $env.PATH = ("@path@" | split row ":") ++ $env.PATH
  $env.NIX_CONFIG = "experimental-features = nix-command flakes"
  let config = $"@flake@#nixosConfigurations.($host).config"

  if (input "Remove all UEFI hard drive boot entries? [y/N] ") == "y" {
    for entry in (^efibootmgr | parse --regex '^Boot(?<number>[0-9A-F]{4})\*? [^\t]*\tHD\(') {
      ^efibootmgr --quiet --bootnum $entry.number --delete-bootnum
    }
  }

  ^nix run $"($config).system.build.destroyFormatMount"
  ^nixos-install --flake $"@flake@#($host)" --no-root-password

  # Enter the new system with the /etc overlay's persisted layer bind-mounted,
  # the way preservation does it at boot. Activation then mounts /etc on it,
  # userborn creates the users, and passwd sets trent's password.
  mkdir /mnt/persist/.rw-etc /mnt/.rw-etc
  ^mount --bind /mnt/persist/.rw-etc /mnt/.rw-etc

  let userborn = (r#'@userborn@'# | from json | get $host)

  print "Login password for trent:"
  ^nixos-enter --root /mnt -c $"export PATH=/run/current-system/sw/bin; ($userborn) && until passwd trent; do :; done"
}
