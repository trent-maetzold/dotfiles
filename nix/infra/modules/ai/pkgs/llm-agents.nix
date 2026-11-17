# Agent CLIs from llm-agents, as `pkgs.llm-agents.<name>`.
{llm-agents, ...}: {
  flake.overlays.llm-agents = llm-agents.overlays.shared-nixpkgs;
}
