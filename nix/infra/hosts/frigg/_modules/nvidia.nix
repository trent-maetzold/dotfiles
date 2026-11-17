# GTX 980 (Maxwell): the legacy 580 driver, which has no open kernel module.
{config, ...}: {
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    open = false;
  };
}
