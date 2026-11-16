# Watching GPUs, power and temperature on any machine (laptops, WSL with
# NVIDIA, servers): nvtop (Intel, NVIDIA, AMD), intel_gpu_top, powertop,
# turbostat (for the running kernel), sensors, vainfo (video decoding) and
# glxinfo/eglinfo.
{
  osConfig,
  pkgs,
  ...
}: {
  home.packages = [
    pkgs.nvtopPackages.full
    pkgs.intel-gpu-tools
    pkgs.powertop
    osConfig.boot.kernelPackages.turbostat
    pkgs.lm_sensors
    pkgs.libva-utils
    pkgs.mesa-demos
  ];
}
