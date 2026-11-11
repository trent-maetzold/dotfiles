# Install one of this flake's hosts onto this machine (booted from a NixOS live
# USB), or onto a remote machine over SSH with nixos-anywhere.

# This flake's source in the Nix store, substituted at build time.
const flake = "@flake@"

def die [message: string] {
  print -e $"(ansi red_bold)bootstrap:(ansi reset) ($message)"
  exit 1
}

def step [message: string] {
  print $"\n(ansi blue_bold)==> ($message)(ansi reset)"
}

# Each disko disk with the GPT partition labels disko gives its partitions.
def disko-disks [host: string]: nothing -> list<record> {
  let expression = r#'
    config: builtins.attrValues (builtins.mapAttrs (name: disk: {
      device = disk.device;
      labels =
        if (disk.content.type or null) == "gpt"
        then builtins.map (partition: partition.label) (builtins.attrValues disk.content.partitions)
        else [];
    }) config.disko.devices.disk)
  '#

  ^nix eval --json $"($flake)#nixosConfigurations.($host).config" --apply $expression | from json
}

# True when every disk already has exactly the partitions the config describes.
def layout-matches [disks: list<record>]: nothing -> bool {
  $disks | all {|disk|
    let current_labels = ^lsblk --noheadings --raw --output PARTLABEL $disk.device
      | lines
      | where $it != ""
      | sort

    ($disk.labels | is-not-empty) and $current_labels == ($disk.labels | sort)
  }
}

def is-reachable [ssh_target: string]: nothing -> bool {
  let address = $ssh_target | split row "@" | last
  (^nc -z -w 5 $address 22 | complete).exit_code == 0
}

# Build one of the host's disko scripts and run it.
def run-disko [host: string, script: string] {
  let script_path = ^nix build --no-link --print-out-paths $"($flake)#nixosConfigurations.($host).config.system.build.($script)"
    | str trim

  ^$script_path
}

# Install nixosConfigurations.<host> onto this machine, or onto <target> over SSH.
#
#   nix run github:trent-maetzold/dotfiles#bootstrap -- muninn
#   nix run github:trent-maetzold/dotfiles#bootstrap -- muninn 192.168.1.50
def --wrapped main [
  host: string                    # one of this flake's nixosConfigurations
  target?: string                 # [user@]address to install over SSH; omit to install here
  ...nixos_anywhere_args: string  # extra nixos-anywhere flags, after --
] {
  # --wrapped hands --help to us as an ordinary argument.
  if $host in [--help -h] or "--help" in $nixos_anywhere_args {
    print (help main)
    exit 0
  }

  $env.PATH = ("@path@" | split row ":") ++ $env.PATH
  # The live ISO ships with flakes disabled.
  $env.NIX_CONFIG = "experimental-features = nix-command flakes"

  let host_names = ^nix eval --json $"($flake)#nixosConfigurations" --apply builtins.attrNames | from json
  if $host not-in $host_names {
    die $"no host '($host)'; available: ($host_names | str join ', ')"
  }

  if $target != null {
    let ssh_target = if "@" in $target { $target } else { $"root@($target)" }
    if not (is-reachable $ssh_target) {
      die $"($target) is not reachable on SSH port 22"
    }

    step $"Installing ($host) on ($ssh_target) with nixos-anywhere \(erases its disks)"
    let extra_args = $nixos_anywhere_args | skip while {|arg| $arg == "--" }
    ^nixos-anywhere --flake $"($flake)#($host)" --target-host $ssh_target ...$extra_args
    return
  }

  # Installing here partitions local disks, which needs root.
  if (^id -u | into int) != 0 {
    exec sudo $env.CURRENT_FILE $host
  }

  step $"Checking disks for ($host)"
  let disks = disko-disks $host
  if ($disks | is-empty) { die $"($host) has no disko disk config" }
  for disk in $disks {
    if ($disk.device | path type) != "block device" { die $"disk ($disk.device) not found" }
  }

  if (layout-matches $disks) {
    step "Disks already match the config; mounting them"
    run-disko $host mountScript
  } else {
    let devices = $disks | get device
    ^lsblk --output NAME,SIZE,MODEL,PARTLABEL,FSTYPE ...$devices
    print $"\nDisks don't match ($host)'s config. Formatting ERASES: ($devices | str join ', ')"
    if (input $"Type '($host)' to continue: ") != $host { die "aborted" }

    step "Partitioning, formatting and mounting"
    run-disko $host diskoScript
  }

  step $"Installing ($host)"
  ^nixos-install --flake $"($flake)#($host)" --no-root-password --no-channel-copy

  step $"Done. Reboot into ($host): reboot"
}
