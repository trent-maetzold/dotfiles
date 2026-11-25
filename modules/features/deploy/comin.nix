{
  flake.modules.nixos.os-deploy-comin =
    # comin: poll this repo's main branch, build nixosConfigurations.<hostName>
    # when it changes, and make it the default for the next boot (not switched
    # under a running session). A testing-<hostName> branch is tried with `test`
    # (live, not kept across reboots). Not in nixosModules.default.
    {inputs, ...}: {
      imports = [inputs.comin.nixosModules.comin];

      services.comin = {
        enable = true;
        remotes = [
          {
            name = "origin";
            url = "https://github.com/trent-maetzold/dotfiles.git";
            branches.main = {
              name = "main";
              operation = "boot";
            };
          }
        ];
      };

      # Its checkout and deployment history.
      preservation.preserveAt."/persist".directories = ["/var/lib/comin"];
    };
}
