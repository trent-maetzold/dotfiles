# llama-swap models small enough for the CPU.
{lib, ...}: let
  makeModel = import ../_lib/make-model.nix {inherit lib;};
in let
  modules.nixos = {
    config,
    lib,
    ...
  }: let
    cfg = config.services.llama-swap;
  in {
    config = {
      services.llama-swap.settings.models = {
        "lfm2.5-2.6b" = makeModel cfg "lfm2.5-2.6b" {
          cmd = lib.mkDefault ''
            ${cfg.llamaServer} --port ''${PORT} --host 127.0.0.1 \
              -hf LiquidAI/LFM2.5-2.6B-GGUF:Q4_K_M \
              --ctx-size 131072 --temp 0.1 --top-k 50 --repeat-penalty 1.1 \
              --jinja --parallel 1 --n-gpu-layers 0 --threads 8 --timeout 900
          '';

          capabilities = {
            "in" = ["text"];
            out = ["text"];
            tools = lib.mkDefault true;
            context = lib.mkDefault 131072;
          };
        };

        "lfm2.5-8b-a1b" = makeModel cfg "lfm2.5-8b-a1b" {
          cmd = lib.mkDefault ''
            ${cfg.llamaServer} --port ''${PORT} --host 127.0.0.1 \
              -hf LiquidAI/LFM2.5-8B-A1B-GGUF:Q4_K_M \
              --ctx-size 128000 --temp 0.1 --top-k 50 --repeat-penalty 1.1 \
              --jinja --parallel 1 --n-gpu-layers 0 --threads 8 --timeout 900
          '';

          capabilities = {
            "in" = ["text"];
            out = ["text"];
            tools = lib.mkDefault true;
            context = lib.mkDefault 128000;
          };
        };
      };
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.llama-swap-models = modules.nixos;
}
