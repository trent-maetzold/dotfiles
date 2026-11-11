# muninn's / is tmpfs: what survives a reboot lives on /persist.
{inputs, ...}: {
  imports = [inputs.preservation.nixosModules.default];

  preservation = {
    enable = true;
    preserveAt."/persist" = {
      directories = [
        "/etc/NetworkManager/system-connections"
        "/etc/nixos"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd"
        "/var/log"
      ];
      files = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
        {
          file = "/etc/ssh/ssh_host_ed25519_key";
          how = "symlink";
          configureParent = true;
        }
        {
          file = "/etc/ssh/ssh_host_rsa_key";
          how = "symlink";
          configureParent = true;
        }
      ];
    };
  };

  systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];
}
