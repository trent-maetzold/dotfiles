# Agent tools from github:numtide/llm-agents.nix.
{ llmAgents, ... }:
{
  home.packages = with llmAgents; [
    beads # bd: issue tracker for agent workflows
    plannotator # plan and code review for agents
    ralph-tui # agent loop orchestrator
  ];
}
