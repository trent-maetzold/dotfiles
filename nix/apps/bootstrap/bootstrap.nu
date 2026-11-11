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

  # The host's hashedPasswordFile for trent; userborn reads it at every boot.
  print "Login password for trent:"
  mkdir /mnt/persist/passwords
  ^chmod 700 /mnt/persist/passwords
  ^mkpasswd --method=yescrypt | save /mnt/persist/passwords/trent
  ^chmod 600 /mnt/persist/passwords/trent

  ^nixos-install --flake $"@flake@#($host)" --no-root-password
}
