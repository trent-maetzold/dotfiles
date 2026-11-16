# sif: Justine's Yoga 720-13IKB (i5-7200U, HD 620, 8 GB). Same encrypted
# ephemeral root as muninn, with a Windows-like Cinnamon desktop. trent
# manages the OS; Justine installs her own apps from Flathub (GNOME Software).
{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    (inputs.import-tree ../../modules/nixos/machine)
    ../../modules/nixos/desktop/cinnamon.nix
    ../../modules/nixos/desktop/flatpak.nix
    ../../modules/nixos/desktop/fonts.nix
    ../../modules/nixos/hardware/intel-graphics.nix
    ../../modules/nixos/deploy/comin.nix
  ];

  networking.hostName = "sif";
  # Generate on the laptop before installing (see README); until then, no report.
  hardware.facter.reportPath = lib.mkIf (builtins.pathExists ./facter.json) ./facter.json;

  # 8 GB of RAM: keep tmpfs / small and compress swap in RAM.
  disko.devices.nodev."/".mountOptions = ["size=2G" "mode=755"];
  zramSwap.enable = true;

  # trent logs in over SSH with his keys only (machine/admin.nix).
  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
  };

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
