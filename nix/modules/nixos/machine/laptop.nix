# Suspend on lid close, whatever the power source; idle sleep is left to the
# desktop. Power modes (power-profiles-daemon) and Intel thermal management.
{
  config,
  pkgs,
  ...
}: {
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "suspend";
    IdleAction = "ignore";
  };
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;
  # Watching GPUs, power and temperature: nvtop (Intel and NVIDIA), intel_gpu_top,
  # powertop, turbostat, sensors, vainfo (video decoding), glxinfo/eglinfo.
  environment.systemPackages = [
    pkgs.nvtopPackages.full
    pkgs.intel-gpu-tools
    pkgs.powertop
    config.boot.kernelPackages.turbostat
    pkgs.lm_sensors
    pkgs.libva-utils
    pkgs.mesa-demos
  ];
}
