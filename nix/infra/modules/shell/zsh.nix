# Zsh with oh-my-zsh, autosuggestions and syntax highlighting.
{config, ...}: let
  modules.homeManager = {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      oh-my-zsh.enable = true;
      oh-my-zsh.plugins = ["sudo"];
      syntaxHighlighting.enable = true;
    };
  };
in {
  # Flake Modules
  flake.modules.homeManager.zsh = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.zsh];
  flake.homeModules.default-slim.imports = [config.flake.modules.homeManager.zsh];
}
