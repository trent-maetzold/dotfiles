# `agents.md`, rendered to ~/.agents/AGENTS.md, and makeAgentRules to fill it:
#   makeAgentRules {boundaries = "- **NEVER** push to main.";}
{lib, ...}: let
  makeAgentsMd = import ../_lib/make-agents-md.nix {inherit lib;};
  makeSectionOptions = import ../_lib/make-section-options.nix {inherit lib;};
in let
  sections = ["context" "boundaries" "workflow" "style" "commands" "tools" "coding-agents"];

  # Keyed so makeAgentRules can import it again without duplicate options.
  md = {
    key = "asgard#flake.modules.homeManager.AGENTS.md";

    imports = [
      ({config, ...}: {
        options.agents.md =
          makeSectionOptions sections
          // {
            # For agents that take AGENTS.md as text (claude-code, codex).
            text = lib.mkOption {
              type = lib.types.str;
              readOnly = true;
              default = makeAgentsMd sections config.agents.md;
            };
          };

        config.home.file.".agents/AGENTS.md".text = config.agents.md.text;
      })
    ];
  };
in {
  # Flake Modules
  flake.modules.homeManager."AGENTS.md".imports = [md];

  # Functions
  flake.lib.makeAgentRules = sections: {
    imports = [md];
    agents.md = builtins.mapAttrs (_: rule: [rule]) sections;
  };
}
