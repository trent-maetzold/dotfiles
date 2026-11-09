{ config, pkgs, ... }:
{
  programs.npm = {
    enable = true;
    settings = {
      cache = "${config.xdg.cacheHome}/npm";
      prefix = "${config.xdg.dataHome}/npm";
      init-module = "${config.xdg.configHome}/npm/npm-init.js";
    };
  };
  programs.pnpm.enable = true;
  programs.bun.enable = true;

  home.packages = with pkgs; [
    typescript
    typescript-language-server
  ];

  home.sessionVariables = {
    NODE_REPL_HISTORY = "${config.xdg.stateHome}/node_repl_history";
    BUN_INSTALL = "${config.xdg.dataHome}/bun";
    BUN_INSTALL_CACHE_DIR = "${config.xdg.cacheHome}/bun/install";
  };

  home.sessionPath = [
    "${config.xdg.dataHome}/npm/bin"
    "${config.xdg.dataHome}/bun/bin"
  ];
}
