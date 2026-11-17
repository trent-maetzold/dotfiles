# DeepSeek's agent harness, dsh.
let
  modules.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.llm-agents.dsh];

    agents.md.coding-agents = [
      "- `dsh`: DeepSeek's agent harness. Headless: `dsh headless \"<task>\"`; the profile's `agentDefaultModel` picks the model and reasoning is the provider default, so no per-run flag."
    ];
  };
in {
  # Flake Modules
  flake.modules.homeManager.dsh = modules.homeManager;
}
