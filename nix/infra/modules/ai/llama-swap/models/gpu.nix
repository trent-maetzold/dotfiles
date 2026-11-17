# llama-swap models that need a GPU.
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
        "ornith-1.5-35b-a3b" = makeModel cfg "ornith-1.5-35b-a3b" {
          cmd = lib.mkDefault ''
            ${cfg.llamaServer} --port ''${PORT} --host 127.0.0.1 \
              -hf ornith-ai/Ornith-1.5-35B-A3B-GGUF:Q4_K_M \
              --no-mmproj --ctx-size 262144 --flash-attn on \
              --cache-type-k q8_0 --cache-type-v q8_0 --jinja --parallel 1 \
              --temp 0.6 --top-p 0.95 --top-k 20 \
              --n-gpu-layers 999 --cpu-moe --threads 8 --timeout 900
          '';

          capabilities = {
            "in" = ["text"];
            out = ["text"];
            tools = lib.mkDefault true;
            context = lib.mkDefault 262144;
          };
        };

        "refact-1.6b-fim" = makeModel cfg "refact-1.6b-fim" {
          cmd = lib.mkDefault ''
            ${cfg.llamaServer} --port ''${PORT} --host 127.0.0.1 \
              -hf mradermacher/Refact-1_6B-fim-i1-GGUF:i1-Q6_K \
              --ctx-size 4096 --flash-attn on --parallel 1 \
              --n-gpu-layers 99 --threads 8 --timeout 900 \
              --cache-reuse 64
          '';

          capabilities = {
            "in" = ["text"];
            out = ["text"];
            tools = lib.mkDefault false;
            context = lib.mkDefault 4096;
          };
        };
      };
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.llama-swap-gpu = modules.nixos;
}
