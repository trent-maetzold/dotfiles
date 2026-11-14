# muninn's / is tmpfs: what survives a reboot lives on /persist.
#
# /etc is an overlay (configuration.nix): Nix's read-only build at the bottom,
# runtime changes in /.rw-etc/upper on top. Persisting that layer keeps /etc's
# state (Wi-Fi, machine-id, SSH host keys, users) and leaves every drift from
# the declared config in one place: `ls -R /.rw-etc/upper`.
{inputs, ...}: {
  imports = [inputs.preservation.nixosModules.default];

  preservation = {
    enable = true;
    preserveAt."/persist".directories = [
      {
        directory = "/.rw-etc";
        inInitrd = true;
      }
      "/var/lib/bluetooth"
      "/var/lib/systemd"
      # userborn's last-applied config, to tell declared users from `useradd` ones.
      "/var/lib/userborn"
      "/var/log"
    ];
  };

  # The overlay's setup only waits for /sysroot; also wait for the bind mount.
  boot.initrd.systemd.services.rw-etc.unitConfig.RequiresMountsFor = ["/sysroot/.rw-etc"];
}
