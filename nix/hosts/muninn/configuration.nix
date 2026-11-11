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

  users.users.trent = {
    isNormalUser = true;
    # userborn sets this when it creates trent at first boot. With mutableUsers,
    # later `passwd` changes persist in /persist/etc/shadow.
    initialHashedPassword = "!"; # locked: replace with a real yescrypt hash
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
