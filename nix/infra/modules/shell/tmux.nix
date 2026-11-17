# tmux with vi keys, mouse, zsh and which-key; windows numbered from 1.
{config, ...}: let
  modules.homeManager = {
    lib,
    pkgs,
    ...
  }: {
    programs.tmux = {
      enable = true;
      terminal = "tmux-256color";
      shell = lib.getExe pkgs.zsh;
      keyMode = "vi";
      clock24 = true;
      mouse = true;
      disableConfirmationPrompt = true;
      baseIndex = 1;
      sensibleOnTop = true;
      plugins = [pkgs.tmuxPlugins.tmux-which-key];

      extraConfig = ''
        set -as terminal-features ",xterm*:RGB"
        set -g extended-keys on
        set -g extended-keys-format csi-u
        set -g renumber-windows on
        setw -g allow-rename off
      '';
    };
  };
in {
  # Flake Modules
  flake.modules.homeManager.tmux = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.tmux];
  flake.homeModules.default-slim.imports = [config.flake.modules.homeManager.tmux];
}
