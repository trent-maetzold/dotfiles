# Standalone (non-WSL) machines: boot, network, nix.
{
  lib,
  pkgs,
  ...
}: {
  networking.networkmanager.enable = true;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # /etc is an overlay; runtime changes land in /.rw-etc (see preservation.nix).
  system.etc.overlay.enable = true;

  services = {
    openssh.enable = true;
    # <host>.local on the LAN, and resolving other hosts' .local names.
    avahi = {
      enable = true;
      nssmdns4 = true;
      settings.publish = {
        disable-publishing = false;
        publish-addresses = true;
      };
    };
    userborn.enable = true;
  };

  security.sudo.wheelNeedsPassword = true;

  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
