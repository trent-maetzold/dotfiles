# Standalone (non-WSL) machines: boot, locale, network, nix.
{
  lib,
  pkgs,
  ...
}: {
  time.timeZone = "America/Chicago";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

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
