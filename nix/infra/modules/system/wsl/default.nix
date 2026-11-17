# NixOS on WSL, using the Windows GPU driver and opening links in Windows.
{
  config,
  nixos-wsl,
  ...
}: let
  modules.nixos = {pkgs, ...}: {
    imports = [nixos-wsl.nixosModules.wsl];

    environment.systemPackages = with pkgs; [
      wslview
      wsl-open
    ];

    wsl = {
      enable = true;
      # Keeps .exe launching when any binfmt (e.g. aarch64 emulation) is registered.
      interop.register = true;
      startMenuLaunchers = true;
      useWindowsDriver = true;
    };
  };

  # The NVIDIA container toolkit on WSL, against the Windows driver.
  modules.nixos-ctk = {pkgs, ...}: {
    hardware = {
      nvidia-container-toolkit.suppressNvidiaDriverAssertion = true;
      nvidia.package = pkgs.wsl-nvidia-driver-stub;
    };
  };
in {
  # Flake Modules
  flake.modules.nixos.wsl = modules.nixos;
  flake.modules.nixos.wsl-ctk = modules.nixos-ctk;

  # NixOS Configuration Modules
  flake.nixosModules.muninn.imports = with config.flake.modules.nixos; [wsl wsl-ctk];
}
