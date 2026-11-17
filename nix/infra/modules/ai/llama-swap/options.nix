# llama-swap's llama-server and its CUDA switch, and one switch per model.
{lib, ...}: let
  makeModelOption = import ./_lib/make-model-option.nix {inherit lib;};
in {
  flake.modules.nixos.llama-swap = {
    config,
    pkgs,
    ...
  }: {
    options.services.llama-swap = {
      cuda.enable = lib.mkEnableOption "cuda support for llama-cpp";

      llamaServer = lib.mkOption {
        type = lib.types.path;
        default = lib.getExe' (
          if config.services.llama-swap.cuda.enable
          then pkgs.llama-cpp.override {cudaSupport = true;}
          else pkgs.llama-cpp
        ) "llama-server";
        description = "llama-server binary used by llama-swap model commands.";
      };
    };
  };

  flake.modules.nixos.llama-swap-models.options.services.llama-swap.models = {
    "lfm2.5-2.6b" = makeModelOption "lfm2.5-2.6b";
    "lfm2.5-8b-a1b" = makeModelOption "lfm2.5-8b-a1b";
  };

  flake.modules.nixos.llama-swap-gpu.options.services.llama-swap.models = {
    "ornith-1.5-35b-a3b" = makeModelOption "ornith-1.5-35b-a3b";
    "refact-1.6b-fim" = makeModelOption "refact-1.6b-fim";
  };
}
