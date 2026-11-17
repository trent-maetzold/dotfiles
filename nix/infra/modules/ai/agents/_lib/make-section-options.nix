# One `agents.md.<section>` list-of-lines option per section.
{lib}: sections:
lib.genAttrs sections (_:
    lib.mkOption {
      type = lib.types.listOf lib.types.lines;
      default = [];
    })
