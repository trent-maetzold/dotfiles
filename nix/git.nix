{
  config,
  vars,
  ...
}: let
  hm = config.flake.modules.homeManager;
in {
  # Rarely changes: declarative.
  flake.modules.homeManager.git = {
    config,
    lib,
    ...
  }: {
    options.dotfiles.git = {
      name = lib.mkOption {
        type = lib.types.str;
        default = vars.git.name;
      };
      email = lib.mkOption {
        type = lib.types.str;
        default = vars.git.email;
      };
    };

    config = {
      programs.git = {
        enable = true;
        settings = {
          user = {inherit (config.dotfiles.git) name email;};
          alias = {
            co = "checkout";
            br = "branch";
            ci = "commit";
            st = "status";
          };
          init.defaultBranch = "master";
          pull.rebase = true;
          push.autoSetupRemote = true;
          diff = {
            algorithm = "histogram";
            colorMoved = "plain";
            mnemonicPrefix = true;
          };
          commit.verbose = true;
          column.ui = "auto";
          branch.sort = "-committerdate";
          tag.sort = "-version:refname";
          rerere = {
            enabled = true;
            autoupdate = true;
          };
        };
      };

      programs.gh = {
        enable = true;
        gitCredentialHelper.enable = true;
      };
    };
  };

  flake.modules.homeManager.default.imports = [hm.git];
}
