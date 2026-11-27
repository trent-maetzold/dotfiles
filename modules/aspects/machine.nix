{config, ...}: {
  flake.modules.nixos.machineProfile = {
    imports = with config.flake.modules.nixos; [
      audio
      machine-base
      disko
      laptop
      locale
      preservation
    ];
  };
}
