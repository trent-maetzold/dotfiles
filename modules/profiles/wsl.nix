{config, ...}: {
  flake.modules.nixos.defaultProfile = {
    imports = with config.flake.modules.nixos; [
      nix
      users
      llama-swap
      quadlet
      wsl
    ];
  };
}
