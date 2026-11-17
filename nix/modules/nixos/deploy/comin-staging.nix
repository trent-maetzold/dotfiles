# Imported infrastructure hosts switch from staging. Their existing persistence
# policy keeps Comin's checkout on tmpfs-root machines and persistent roots alike.
{inputs, ...}: {
  imports = [inputs.comin.nixosModules.comin];

  services.comin = {
    enable = true;
    remotes = [
      {
        name = "origin";
        url = "https://github.com/trent-maetzold/dotfiles.git";
        branches.main = {
          name = "staging";
          operation = "switch";
        };
      }
    ];
  };

  persistence.dirs."/var/lib/comin" = {};
}
