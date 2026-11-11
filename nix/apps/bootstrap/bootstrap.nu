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

  # Passwords come from the config: userborn applies them at first boot.
  ^nixos-install --flake $"@flake@#($host)" --no-root-password
}
