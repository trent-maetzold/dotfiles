# AGENTS.md text from its sections, in order, each under a `## Sentence case` heading.
{lib}: sections: md: let
  # Agent modules append their own line; sort so the section order is stable.
  ordered = name: rules:
    if name == "coding-agents"
    then lib.sort builtins.lessThan rules
    else rules;
  render = name: rules: lib.optionalString (rules != []) "## ${lib.toSentenceCase (lib.replaceStrings ["-"] [" "] name)}\n\n${lib.concatLines (ordered name rules)}";
in
  lib.concatStringsSep "\n" (lib.filter (s: s != "") (map (s: render s md.${s}) sections))
