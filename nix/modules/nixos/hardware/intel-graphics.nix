# Intel VA-API (Broadwell and newer): hardware video decoding for browsers.
{pkgs, ...}: {
  hardware.graphics = {
    enable = true;
    extraPackages = [pkgs.intel-media-driver];
  };
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
}
