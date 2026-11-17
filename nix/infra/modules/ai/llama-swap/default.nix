# llama-swap serving llama.cpp models on demand, with CUDA when enabled.
let
  modules.nixos = {
    config,
    lib,
    ...
  }: let
    cfg = config.services.llama-swap;
    wslEnabled = config.wsl.enable or false;
  in {
    config = {
      services.llama-swap.enable = true;

      nixpkgs.config.allowUnfreePackages = lib.optionals cfg.cuda.enable [
        "cuda_cccl"
        "cuda_cudart"
        "cuda_nvcc"
        "cuda_nvrtc"
        "libcublas"
      ];

      services.llama-swap.settings = {
        healthCheckTimeout = 1800;
        metricsMaxInMemory = 3600;
      };

      systemd.services.llama-swap.environment.LD_LIBRARY_PATH =
        lib.mkIf (wslEnabled && cfg.cuda.enable)
        (lib.mkDefault "/usr/lib/wsl/lib");
      warnings =
        lib.optional
        ((cfg.settings.models or {}) == {})
        "llama-swap is enabled but no models are configured (services.llama-swap.settings.models). The service will serve nothing.";
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.llama-swap = modules.nixos;
}
