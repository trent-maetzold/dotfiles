# NVIDIA as a PRIME offload GPU: the integrated GPU drives the displays, and
# the NVIDIA one powers off when idle (RTD3, Turing and newer) until a program
# asks for it: `nvidia-offload <command>`, or an app launched on the discrete
# GPU (switcheroo-control). Hosts set hardware.nvidia.prime.*BusId.
{
  services.xserver.videoDrivers = ["modesetting" "nvidia"];
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    prime.offload = {
      enable = true;
      enableOffloadCmd = true;
    };
  };
  services.switcherooControl.enable = true;
  nixpkgs.config.allowUnfreePackages = ["nvidia-x11" "nvidia-settings"];
}
