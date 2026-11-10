# Shared agent config and agent tools.
{
  config,
  pkgs,
  ...
}: {
  home.file.".agents".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/config/agents";

  home.packages =
    [
      # openwiki CLI; its pi extension is installed by pi ("npm:openwiki" in config/pi/agent/settings.json).
      pkgs.openwiki-cli
    ]
    ++ (with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
      beads # bd: issue tracker for agent workflows
      plannotator # plan and code review for agents
      ralph-tui # agent loop orchestrator
    ]);
}
