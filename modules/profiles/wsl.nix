{config, ...}: {
  flake.modules.nixos.defaultProfile = {
    imports = with config.flake.modules.nixos; [
      os-common-nix
      os-common-users
      os-services-llama-swap
      os-services-quadlet
      os-wsl-wsl
    ];
  };
}
