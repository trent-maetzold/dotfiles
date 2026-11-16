# comin: poll this repo's main branch and switch to nixosConfigurations.<hostName>
# when it changes. A testing-<hostName> branch is tried with `test` (not kept
# across reboots). Not in nixosModules.default.
{inputs, ...}: {
  imports = [inputs.comin.nixosModules.comin];

  services.comin = {
    enable = true;
    remotes = [
      {
        name = "origin";
        url = "https://github.com/trent-maetzold/dotfiles.git";
        branches.main.name = "main";
      }
    ];
  };

  # Its checkout and deployment history.
  preservation.preserveAt."/persist".directories = ["/var/lib/comin"];
}
