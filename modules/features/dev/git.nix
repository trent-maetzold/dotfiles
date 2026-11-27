{inputs, ...}: {
  flake.modules.homeManager.git = {
    lib,
    pkgs,
    ...
  }: {
    programs.git = {
      enable = true;
      lfs.enable = true;
      settings = {
        # Settings after github:ryan4yin/nix-config (home/base/core/git.nix).
        init.defaultBranch = "main";
        trim.bases = "dev,develop,master,main"; # git-trim
        push.autoSetupRemote = true;
        pull.rebase = true;
        log.date = "iso";
      };
    };

    programs.delta.options = {
      diff-so-fancy = true;
      line-numbers = true;
      true-color = "always";
    };

    programs.jujutsu.enable = true;

    programs.gh.enable = true;
    programs.lazygit.enable = true;
    home.packages = [
      pkgs.git-trim
      pkgs.gitleaks
      # GitButler CLI: virtual branches and stacked diffs. From llm-agents.nix
      # (prebuilt, numtide cache); nixpkgs' build is broken and marked unfree.
      inputs.zoldt-agents.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.but
    ];

    # oh-my-zsh's git plugin aliases (gst, gco, gcmsg, ...), nushell-only: nu_scripts'
    # port, some calling nushell functions. After nushell.nix's NU_LIB_DIRS.
    programs.nushell.extraConfig = lib.mkAfter ''
      use aliases/git/git-aliases.nu *
    '';
  };
}
