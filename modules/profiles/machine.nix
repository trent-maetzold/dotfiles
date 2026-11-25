{config, ...}: {
  flake.modules.nixos.machineProfile = {
    imports = with config.flake.modules.nixos; [
      admin
      audio
      machine-base
      disko
      laptop
      locale
      preservation
    ];
  };
}
