# NVIDIA GPU monitors for the terminal.
{config, ...}: {
  # Flake Modules
  flake.modules.homeManager.nvidia-tools = {pkgs, ...}: {
    home.packages = with pkgs; [nvtopPackages.nvidia nvitop python3Packages.gpustat];
  };

  # Home Configuration Modules
  flake.homeModules.trent.imports = [config.flake.modules.homeManager.nvidia-tools];
}
