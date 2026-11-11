# muninn's base system: boot, locale, users.
{
  lib,
  pkgs,
  ...
}: {
  hardware.facter.reportPath = ./facter.json;

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

  networking = {
    hostName = "muninn";
    networkmanager.enable = true;
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # / and /etc are wiped every boot, so `passwd` can't persist. Passwords are
  # hash files on /persist (bootstrap writes them); change one by rewriting it:
  #   mkpasswd --method=yescrypt | sudo tee /persist/passwords/trent
  users.mutableUsers = false;
  users.users.trent = {
    isNormalUser = true;
    hashedPasswordFile = "/persist/passwords/trent";
    extraGroups = ["networkmanager" "wheel"];
  };

  services = {
    openssh.enable = true;
    userborn = {
      enable = true;
      passwordFilesLocation = "/persist/etc";
    };
  };

  security.sudo.wheelNeedsPassword = true;

  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "26.11";
}
