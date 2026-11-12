# Shared agent config and agent tools.
{
  config,
  pkgs,
  llm-agents,
  ...
}: {
  home.file.".agents".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/config/agents";

  home.packages =
    [
      # openwiki CLI; its pi extension is installed by pi ("npm:openwiki" in config/pi/agent/settings.json).
      pkgs.openwiki-cli
      pkgs.rtk # CLI proxy that trims command output for agents
      pkgs.mu-coding-agent # pi plus a small judge model for yes/no calls (~/.mu)
    ]
    ++ (with llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
      beads # bd: issue tracker for agent workflows
      plannotator # plan and code review for agents
      ralph-tui # agent loop orchestrator
    ]);

  home.shellAliases.rt = "ralph-tui";
}
