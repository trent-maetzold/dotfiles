# The `services.llama-swap.models.<name>` switch for one model.
{lib}: name:
lib.mkOption {
  type = lib.types.bool;
  default = false;
  description = "Serve the '${name}' llama-swap model.";
}
