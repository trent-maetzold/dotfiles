# The `settings.models.<name>` definition, set only if its switch is on: `cfg` is
# services.llama-swap, `def` the llama-swap model attrset.
{lib}: cfg: name: def: lib.mkIf cfg.models.${name} def
