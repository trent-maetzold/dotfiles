# NVIDIA container toolkit, for GPUs in containers.
{config, ...}: let
  modules.nixos = {
    hardware.nvidia-container-toolkit.enable = true;
    nixpkgs.config.allowUnfreePackages = ["nvidia-container-toolkit"];
  };
in {
  # Flake Modules
  flake.modules.nixos.nvidia-ctk = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.muninn.imports = [config.flake.modules.nixos.nvidia-ctk];
}
