# Git, lazygit, gh and forgejo-cli.
{config, ...}: let
  modules.homeManager = {pkgs, ...}: {
    home = {
      packages = [pkgs.forgejo-cli];
      shellAliases.lg = "lazygit";
    };

    programs = {
      gh.enable = true;
      lazygit.enable = true;
      zsh.oh-my-zsh.plugins = ["git"];

      git = {
        enable = true;
        ignores = [".pi-lens-probe-home" ".serena"];

        settings = {
          init.defaultBranch = "main";
          pull.rebase = true;
          push.autoSetupRemote = true;
        };
      };
    };
  };
in {
  # Flake Modules
  flake.modules.homeManager.git = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.git];
  flake.homeModules.default-slim.imports = [config.flake.modules.homeManager.git];
}
