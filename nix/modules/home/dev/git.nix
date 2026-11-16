{
  llm-agents,
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

  programs.jujutsu = {
    enable = true;
    settings.user = {
      name = user.fullName;
      inherit (user) email;
    };
  };

  programs.gh.enable = true;
  programs.lazygit.enable = true;
  home.packages = [
    pkgs.git-trim
    pkgs.gitleaks
    # GitButler CLI: virtual branches and stacked diffs. From llm-agents.nix
    # (prebuilt, numtide cache); nixpkgs' build is broken and marked unfree.
    llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.but
  ];
}
