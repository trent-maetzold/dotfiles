{
  # Rarely changes: declarative.
  flake.homeModules.git = {
    config,
    lib,
    ...
  }: {
    options.dotfiles.git.enable = lib.mkEnableOption "git config";

    config = lib.mkIf config.dotfiles.git.enable {
      programs.git = {
        enable = true;
        settings = {
          user = {
            name = "Trent Maetzold";
            email = "trent@maetzold.net";
          };
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
}
