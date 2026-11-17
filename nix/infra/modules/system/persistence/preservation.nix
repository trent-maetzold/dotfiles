# Keeps `persistence` state on /persist with preservation, for hosts whose `/`
# is a tmpfs.
{
  config,
  lib,
  preservation,
  ...
}: let
  makePreserved = import ./_lib/make-preserved.nix {inherit lib;};
in let
  modules.nixos = {config, ...}: {
    imports = [preservation.nixosModules.default];

    persistence.plain = "preservation";
    # Its commit would fail; the machine-id already lives on /persist.
    systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];

    # Passwords set at runtime survive the wipe.
    services.userborn = {
      enable = true;
      passwordFilesLocation = "/persist/etc";
    };

    preservation = {
      enable = true;

      preserveAt."/persist" = {
        directories =
          [
            "/var/lib/systemd"
            "/var/log"
            {
              directory = "/var/lib/nixos";
              inInitrd = true;
            }
          ]
          ++ makePreserved "directory" config.persistence.dirs;

        files =
          [
            {
              file = "/etc/machine-id";
              inInitrd = true;
            }
            {
              file = "/etc/ssh/ssh_host_rsa_key";
              how = "symlink";
              configureParent = true;
            }
            {
              file = "/etc/ssh/ssh_host_ed25519_key";
              how = "symlink";
              configureParent = true;
            }
          ]
          ++ makePreserved "file" config.persistence.files;
      };
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.preservation = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules = {
    frigg.imports = [config.flake.modules.nixos.preservation];
    thor.imports = [config.flake.modules.nixos.preservation];
  };
}
