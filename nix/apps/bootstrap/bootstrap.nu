# Install one of this flake's hosts onto this machine with disko-install (from
# a NixOS live USB), or onto a remote machine over SSH with nixos-anywhere.

# Substituted at build time (see default.nix): this flake's source in the Nix
# store, and each host's disks and password files, read from its config.
const flake = "@flake@"
const hosts_json = r#'@hosts@'#

const ssh_options = [-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR]

def die [message: string] {
  print -e $"(ansi red_bold)bootstrap:(ansi reset) ($message)"
  exit 1
}

def step [message: string] {
  print $"\n(ansi blue_bold)==> ($message)(ansi reset)"
}

def ask [question: string]: nothing -> bool {
  (input $"($question) [y/N] " | str lowercase) in [y yes]
}

# Run a shell command here, or on ssh_target when given.
def run-on [ssh_target: any, command: string]: nothing -> string {
  if $ssh_target == null {
    ^sh -c $command
  } else {
    ^ssh ...$ssh_options $ssh_target $command
  }
}

# Delete every UEFI boot entry that points at a disk partition, except the one
# this machine booted from.
def remove-disk-boot-entries [ssh_target: any] {
  # The kexec installer may not ship efibootmgr; fetch it there.
  let efibootmgr = if $ssh_target == null {
    "efibootmgr"
  } else {
    "NIX_CONFIG='experimental-features = nix-command flakes' nix shell nixpkgs#efibootmgr -c efibootmgr"
  }

  let listing = run-on $ssh_target $efibootmgr | lines
  let booted_from = $listing | parse "BootCurrent: {number}" | get number.0? | default ""
  let disk_entries = $listing
    | parse --regex '^Boot(?<number>[0-9A-F]{4})\*? (?<label>[^\t]*)\t(?<path>.*)$'
    | where {|entry| "HD(" in $entry.path and $entry.number != $booted_from }

  for entry in $disk_entries {
    print $"    removing Boot($entry.number) ($entry.label)"
    run-on $ssh_target $"($efibootmgr) --quiet --bootnum ($entry.number) --delete-bootnum" | ignore
  }
}

def read-password [prompt: string]: nothing -> string {
  mut password = ""
  while $password == "" {
    let first = input -s $"    ($prompt): "
    print ""
    let second = input -s "    again: "
    print ""

    if $first != "" and $first == $second {
      $password = $first
    } else {
      print "    empty or mismatched; try again"
    }
  }
  $password
}

# Ask for every password the install needs and write them under secrets_dir:
# disk passphrases as plain files, user passwords as yescrypt hashes in a
# `root` tree mirroring where they go on the new system.
def collect-passwords [host_info: record, secrets_dir: string]: nothing -> list<record> {
  let disk_passwords = $host_info.diskPasswordFiles | enumerate | each {|entry|
    step $"Disk encryption passphrase \(used at every boot)"
    let local_file = $secrets_dir | path join $"disk-password-($entry.index)"
    read-password "passphrase" | save $local_file
    {target_path: $entry.item, local_file: $local_file}
  }

  for user in $host_info.userPasswordFiles {
    step $"Login password for ($user.name)"
    let hash_file = $secrets_dir | path join $"root($user.file)"
    mkdir ($hash_file | path dirname)
    read-password "password" | ^mkpasswd --method=yescrypt --stdin | save $hash_file
    ^chmod 600 $hash_file
  }

  $disk_passwords
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

  # disko-install partitions local disks, which needs root.
  if $target == null and (^id -u | into int) != 0 {
    exec sudo $env.CURRENT_FILE $host
  }

  let hosts = $hosts_json | from json
  if $host not-in $hosts {
    die $"no host '($host)'; available: ($hosts | columns | str join ', ')"
  }
  let host_info = $hosts | get $host

  let ssh_target = if $target == null {
    null
  } else if "@" in $target {
    $target
  } else {
    $"root@($target)"
  }
  let machine = $ssh_target | default "this machine"

  # 1. The disks the config names have to exist (disko doesn't check first).
  step $"Checking ($host)'s disks on ($machine)"
  let disks = $host_info.disks
  if ($disks | is-empty) { die $"($host) has no disko disks" }

  if $ssh_target != null {
    let address = $ssh_target | split row "@" | last
    if (^nc -z -w 5 $address 22 | complete).exit_code != 0 {
      die $"($target) is not reachable on SSH port 22"
    }
  }
  for disk in $disks {
    let found = (run-on $ssh_target $"test -e ($disk.device) && echo found" | complete).stdout | str contains "found"
    if not $found { die $"disk '($disk.name)' \(($disk.device)) not found on ($machine)" }
    print $"    ($disk.name): ($disk.device)"
  }

  # 2. Boot entries. (disko always recreates the partition table.)
  let remove_boot_entries = ask "Remove all UEFI hard drive boot entries?"

  # 3. Passwords, so the install runs unattended once confirmed.
  let secrets_dir = ^mktemp -d | str trim
  let disk_passwords = collect-passwords $host_info $secrets_dir

  # 4. Confirm twice.
  let devices = $disks | get device | str join ", "
  print $"\nThis repartitions and DESTROYS the data on ($devices) on ($machine)."
  if not ((ask "Continue?") and (ask $"Really destroy everything on ($devices)?")) {
    rm -rf $secrets_dir
    die "aborted"
  }

  # 5. Install, then remove the passwords whether or not it worked.
  let failure = try {
    if $ssh_target == null {
      install-here $host $disks $remove_boot_entries $secrets_dir $disk_passwords
    } else {
      let extra_args = $nixos_anywhere_args | skip while {|arg| $arg == "--" }
      install-remotely $host $ssh_target $remove_boot_entries $secrets_dir $disk_passwords $extra_args
    }
    null
  } catch {|error| $error }

  # Installing here also put each passphrase where the config looks for it.
  let local_password_copies = if $ssh_target == null { $disk_passwords | get target_path } else { [] }
  rm -rf $secrets_dir ...$local_password_copies
  if $failure != null {
    print -e $failure.rendered
    exit 1
  }
}

def install-here [
  host: string
  disks: list<record>
  remove_boot_entries: bool
  secrets_dir: string
  disk_passwords: list<record>
] {
  if $remove_boot_entries {
    step "Removing UEFI hard drive boot entries"
    remove-disk-boot-entries null
  }

  # disko reads each passphrase from the path the config names.
  for disk_password in $disk_passwords {
    ^install -m 600 $disk_password.local_file $disk_password.target_path
  }

  let disk_args = $disks | each {|disk| [--disk $disk.name $disk.device] } | flatten
  let hash_root = $secrets_dir | path join root
  let extra_file_args = if ($hash_root | path exists) {
    glob $"($hash_root)/**/*"
      | where ($it | path type) == file
      | each {|file| [--extra-files $file ($file | str replace $hash_root "")] }
      | flatten
  } else { [] }

  step $"Installing ($host) with disko-install"
  (^disko-install --flake $"($flake)#($host)" --mode format --write-efi-boot-entries
    ...$disk_args ...$extra_file_args)

  step $"Done. Reboot into ($host): reboot"
}

def install-remotely [
  host: string
  ssh_target: string
  remove_boot_entries: bool
  secrets_dir: string
  disk_passwords: list<record>
  extra_args: list<string>
] {
  step $"Booting ($ssh_target) into the nixos-anywhere installer"
  ^nixos-anywhere --flake $"($flake)#($host)" --target-host $ssh_target --phases kexec ...$extra_args

  # After kexec the installer accepts root with the same key.
  let installer = $"root@($ssh_target | split row '@' | last)"
  if $remove_boot_entries {
    step "Removing UEFI hard drive boot entries"
    remove-disk-boot-entries $installer
  }

  let key_args = $disk_passwords
    | each {|disk_password| [--disk-encryption-keys $disk_password.target_path $disk_password.local_file] }
    | flatten
  let hash_root = $secrets_dir | path join root
  let extra_file_args = if ($hash_root | path exists) { [--extra-files $hash_root] } else { [] }

  step $"Installing ($host) on ($installer) with nixos-anywhere"
  (^nixos-anywhere --flake $"($flake)#($host)" --target-host $installer
    --phases disko,install,reboot ...$key_args ...$extra_file_args ...$extra_args)

  step $"Done. ($host) is rebooting."
}
