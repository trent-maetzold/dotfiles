{
  pkgs,
  user,
  ...
}: {
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        name = user.fullName;
        inherit (user) email;
      };
      # Settings and aliases after github:ryan4yin/nix-config (home/base/core/git.nix).
      init.defaultBranch = "main";
      trim.bases = "develop,master,main"; # git-trim
      push.autoSetupRemote = true;
      pull.rebase = true;
      log.date = "iso";
      alias = {
        br = "branch";
        co = "checkout";
        st = "status";
        ls = ''log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate'';
        ll = ''log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --numstat'';
        cm = "commit -m";
        ca = "commit -am";
        dc = "diff --cached";
        amend = "commit --amend -m";
        unstage = "reset HEAD --";
        merged = "branch --merged";
        unmerged = "branch --no-merged";
        nonexist = "remote prune origin --dry-run";
        delmerged = ''! git branch --merged | egrep -v "(^\*|main|master|dev|staging)" | xargs git branch -d'';
        delnonexist = "remote prune origin";
        update = "submodule update --init --recursive";
        foreach = "submodule foreach";
      };
    };
  };

  programs.delta.options = {
    diff-so-fancy = true;
    line-numbers = true;
    true-color = "always";
  };

  programs.gh.enable = true;
  programs.lazygit.enable = true;
  home.packages = with pkgs; [git-trim gitleaks];
}
