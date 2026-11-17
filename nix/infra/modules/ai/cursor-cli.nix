# Cursor CLI (`cursor-agent`).
let
  modules.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.llm-agents.cursor-agent];

    agents.md.coding-agents = [
      "- `cursor-cli`: Cursor CLI, command `cursor-agent`. Headless: `cursor-agent -p --model <model[:variant]> \"<prompt>\"`; effort is the model variant slug (e.g. `gpt-5-high`)."
    ];
  };
in {
  # Flake Modules
  flake.modules.homeManager.cursor-cli = modules.homeManager;
}
