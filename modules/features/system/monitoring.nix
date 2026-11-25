{
  flake.modules.homeManager.monitoring =
    # Watching GPUs, power and temperature on any machine (laptops, WSL with
    # NVIDIA, servers): nvtop (Intel, NVIDIA, AMD), nvitop (NVIDIA), intel_gpu_top, powertop,
    # turbostat, sensors, vainfo (video decoding) and
    # glxinfo/eglinfo.
    {pkgs, ...}: {
      home.packages = [
        pkgs.nvtopPackages.full
        pkgs.nvitop
        pkgs.intel-gpu-tools
        pkgs.powertop
        pkgs.linuxPackages.turbostat
        pkgs.lm_sensors
        pkgs.libva-utils
        pkgs.mesa-demos
      ];
    };
}
