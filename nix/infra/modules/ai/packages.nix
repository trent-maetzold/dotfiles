# CLI tools for agents (browser, code graph, docs search, diff review), listed
# in AGENTS.md.
{config, ...}: let
  modules.homeManager = {pkgs, ...}: {
    agents.md.tools = [
      "- `agent-browser`: drive a headless browser: `agent-browser open <url>`, then `snapshot`, `click`, `fill`."
      "- `bernstein`: govern agent runs, deterministic scheduling, isolated worktrees, signed audit trail: `bernstein`."
      "- `but`: GitButler CLI, virtual branches and stacked commits: `but`."
      "- `codegraph`: semantic code graph for the repo; `codegraph init` once, auto-syncs. Use `codegraph_explore` over MCP."
      "- `gnhf`: keep coding agents running unattended: `gnhf`."
      "- `jscpd`: copy/paste detector: `jscpd --threshold 5 .`."
      "- `lumen`: view a diff or review a commit in a TUI: `lumen diff`, `lumen diff HEAD~1`."
      "- `plannotator`: review a plan, doc or diff in the browser with inline notes: `plannotator annotate plan.md`, `plannotator review`."
      "- `qmd`: local search over docs and notes: `qmd search <query>`."
      "- `revdiff`: annotate a diff, file or doc line by line in a TUI; notes print to stdout on quit: `revdiff main`, `revdiff --staged`."
      "- `rtk`: prefix noisy commands to compact their output: `rtk git status`, `rtk cargo test`."
      "- `tuicr`: review an AI-generated diff like a pull request: `tuicr`."
      "- `ffmpeg`, `jq`, `ungoogled-chromium`: base utilities; `agent-browser` drives the Chromium."
    ];

    home.packages = with pkgs;
      [ffmpeg jq lumen revdiff ungoogled-chromium]
      ++ (with llm-agents; [
        agent-browser
        bernstein
        but
        codegraph
        gnhf
        jscpd
        plannotator
        qmd
        rtk
        tuicr
      ]);
  };
in {
  # Flake Modules
  flake.modules.homeManager.pkgs-ai = modules.homeManager;

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.pkgs-ai];
}
