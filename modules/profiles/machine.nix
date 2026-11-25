{config, ...}: {
  flake.modules.nixos.machineProfile = {
    imports = with config.flake.modules.nixos; [
      os-machine-admin
      os-machine-audio
      os-machine-base
      os-machine-disko
      os-machine-laptop
      os-machine-locale
      os-machine-preservation
    ];
  };
}
