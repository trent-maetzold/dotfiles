{
  flake.modules.nixos.os-hardware-nvidia-prime =
    # NVIDIA as a PRIME offload GPU, on nixos-hardware's prime profile: the
    # integrated GPU drives the displays, and the NVIDIA one powers off when idle
    # (RTD3, Turing and newer) until a program asks for it: `nvidia-offload
    # <command>`, or an app launched on the discrete GPU (switcheroo-control).
    # Hosts import their NVIDIA generation's profile and set
    # hardware.nvidia.prime.*BusId.
    {inputs, ...}: {
      imports = [inputs.nixos-hardware.nixosModules.common-gpu-nvidia];
      hardware.nvidia.powerManagement = {
        enable = true;
        finegrained = true;
      };
      services.switcherooControl.enable = true;
      # WirePlumber's libcamera starts a GPU image processor and takes the first
      # EGL device it finds, NVIDIA's, keeping it awake. It only sees Mesa (the
      # integrated GPU); programs started with nvidia-offload still get NVIDIA.
      systemd.user.services.wireplumber.environment.__EGL_VENDOR_LIBRARY_FILENAMES = "/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json";
      nixpkgs.config.allowUnfreePackages = ["nvidia-x11" "nvidia-settings"];
    };
}
