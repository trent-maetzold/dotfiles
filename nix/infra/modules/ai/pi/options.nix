# Extensions built into pi-plugins: features add their npm names, `just pi-plugins` locks them.
{lib, ...}: {
  options.pi.plugins = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "npm names of the pi extensions in pi-plugins.";
  };
}
