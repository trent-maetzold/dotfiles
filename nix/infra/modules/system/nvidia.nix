# NVIDIA's proprietary driver, with the open kernel module; older cards set
# `hardware.nvidia.package` and `open = false`.
{config, ...}: let
  modules.nixos = {lib, ...}: {
    services.xserver.videoDrivers = ["nvidia"];
    nixpkgs.config.allowUnfreePackages = ["nvidia-x11" "nvidia-kernel-modules" "nvidia-settings"];
    hardware.nvidia.open = lib.mkDefault true;
  };
in {
  # Flake Modules
  flake.modules.nixos.nvidia = modules.nixos;

  # NixOS Configuration Modules
  flake.nixosModules.nvidia.imports = [config.flake.modules.nixos.nvidia];
}
