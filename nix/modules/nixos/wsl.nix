# NixOS-WSL: on when the host sets wsl.enable.
{
  config,
  lib,
  pkgs,
  nixos-wsl,
  user,
  ...
}: {
  imports = [nixos-wsl.nixosModules.default];

  config = lib.mkIf config.wsl.enable {
    wsl.defaultUser = user.name;

    # Open files/URLs in Windows apps; xdg-open and $BROWSER route through wsl-open.
    environment.systemPackages = with pkgs; [
      wsl-open
      (writeShellScriptBin "xdg-open" ''exec ${wsl-open}/bin/wsl-open "$@"'')
      # The Windows driver's nvidia-smi; it finds NVML only on the driver path.
      (writeShellScriptBin "nvidia-smi" ''LD_LIBRARY_PATH=/run/opengl-driver/lib exec /usr/lib/wsl/lib/nvidia-smi "$@"'')
    ];
    environment.variables.BROWSER = "wsl-open";

    # GPUs in containers (`--device nvidia.com/gpu=all`), against the Windows
    # driver that WSL mounts at /usr/lib/wsl/lib; the NixOS driver is an empty stub.
    wsl.useWindowsDriver = true;
    hardware.nvidia-container-toolkit.enable = true;
    hardware.nvidia-container-toolkit.suppressNvidiaDriverAssertion = true;
    hardware.nvidia.package = pkgs.runCommand "wsl-nvidia-driver-stub" {outputs = ["out" "lib"];} "mkdir -p $out $lib";
    nixpkgs.config.allowUnfreePackages = ["nvidia-container-toolkit"];
    # WSL's libcuda dlopens libdxcore.so by bare name, so CUDA programs need the
    # driver dir on the search path.
    systemd.services.llama-swap.environment.LD_LIBRARY_PATH = "/run/opengl-driver/lib";
  };
}
