# Agent skills via agent-skills-nix, linked to ~/.agents/skills (codex, pi) and
# ~/.claude/skills. Add registry skills with
# `programs.agent-skills.{sources.<name>.path, skills.enable}`, or write one with
# makeAgentSkill. `scripts` and `references` map file names to text or paths;
# scripts are executable.
{
  agent-skills,
  awesome-copilot,
  config,
  i-have-adhd,
  ...
}: let
  # Keyed so makeAgentSkill can import it again without duplicate options.
  skills = {
    key = "asgard#flake.modules.homeManager.agent-skills";
    imports = [agent-skills.homeManagerModules.default];

    programs.agent-skills = {
      enable = true;

      targets = {
        agents = {
          dest = ".agents/skills";
          structure = "link";
        };

        claude = {
          dest = ".claude/skills";
          structure = "link";
        };
      };
    };
  };
in {
  # Flake Modules
  flake.modules.homeManager.agent-skills = {
    imports = [skills];

    programs.agent-skills = {
      sources = {
        awesome-copilot = {
          path = awesome-copilot;
          subdir = "skills";
        };

        i-have-adhd = {
          path = i-have-adhd;
          subdir = "skills";
        };
      };

      skills.enable = ["git-commit" "i-have-adhd"];
    };
  };

  # Home Configuration Modules
  flake.homeModules.default.imports = [config.flake.modules.homeManager.agent-skills];

  # Functions
  flake.lib.makeAgentSkill = {name, ...} @ skill: {pkgs, ...}: let
    agent-skill = pkgs.callPackage ./_lib/agent-skill.nix skill;
  in {
    imports = [skills];

    programs.agent-skills = {
      sources.${name}.path = agent-skill;

      skills.explicit.${name}.from = name;
    };
  };
}
