# sif: Justine's Yoga 720-13IKB (i5-7200U, HD 620, 8 GB). Same encrypted
# ephemeral root as muninn, with a light Windows-like XFCE desktop. trent
# manages the OS; Justine installs her own apps from Flathub (GNOME Software).
{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    (inputs.import-tree ../../modules/nixos/machine)
    ../../modules/nixos/desktop/xfce.nix
    ../../modules/nixos/desktop/flatpak.nix
    ../../modules/nixos/desktop/fonts.nix
    ../../modules/nixos/hardware/intel-graphics.nix
  ];

  networking.hostName = "sif";
  # Generate on the laptop before installing (see README); until then, no report.
  hardware.facter.reportPath = lib.mkIf (builtins.pathExists ./facter.json) ./facter.json;

  # 8 GB of RAM: keep tmpfs / small and compress swap in RAM.
  disko.devices.nodev."/".mountOptions = ["size=2G" "mode=755"];
  zramSwap.enable = true;

  # Set her password once with `sudo passwd justine`.
  users.users.justine = {
    isNormalUser = true;
    description = "Justine Maetzold";
    extraGroups = ["networkmanager"];
  };

  # Chrome from Nix, not Flathub: one managed copy with the Intel video driver.
  environment.systemPackages = [pkgs.google-chrome];
  nixpkgs.config.allowUnfreePackages = ["google-chrome"];

  system.stateVersion = "26.11";
}
