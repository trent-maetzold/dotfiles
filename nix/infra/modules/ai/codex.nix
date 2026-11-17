# OpenAI Codex CLI with the shared AGENTS.md and MCP servers.
{config, ...}: let
  modules.homeManager = {
    config,
    lib,
    pkgs,
    ...
  }: {
    programs.codex = {
      enable = true;
      package = lib.mkDefault pkgs.llm-agents.codex;
      context = config.agents.md.text;
      enableMcpIntegration = true;
      # Codex rewrites config.toml at runtime; merge instead of a read-only store link.
      mutableSettings = true;
    };

    agents.md.coding-agents = [
      "- `codex`: OpenAI Codex CLI. Headless: `codex exec -m <model> -c model_reasoning_effort=\"<low|medium|high|xhigh|max>\" \"<prompt>\"`."
    ];
  };
in {
  # Flake Modules
  flake.modules.homeManager.codex = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.codex];
}
