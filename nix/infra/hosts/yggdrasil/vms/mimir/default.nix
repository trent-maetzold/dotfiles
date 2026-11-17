# yggdrasil-mimir: the Unraid VM on yggdrasil, with its HBA passed through.
# Not NixOS: it is its own host for its address, with no nixosConfiguration.
{config, ...}: {
  flake.hosts.yggdrasil-mimir = config.flake.lib.makeHost {
    name = "yggdrasil-mimir";
    address = "mimir.ts.trkm.io";

    ssh = {
      yggdrasil-mimir.User = "root";

      # The VM's console, from yggdrasil's loopback.
      yggdrasil-vnc = {
        HostName = "yggdrasil.ts.trkm.io";
        LocalForward = "5900 127.0.0.1:5900";
        ExitOnForwardFailure = "yes";
      };
    };
  };

  # The domain on yggdrasil that runs it.
  flake.nixosModules.yggdrasil.imports = [./_modules/libvirt.nix];
}
