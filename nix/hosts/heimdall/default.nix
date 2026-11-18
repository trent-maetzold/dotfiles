{
  inputs,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    inputs.nix-index-database.nixosModules.nix-index
    inputs.comin.nixosModules.comin
    ./edge.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";
  networking.hostName = "heimdall";
  system.stateVersion = "26.11";

  boot = {
    # The OCI image's 249 MiB ESP only fits two kernel copies during a switch.
    loader.grub = {
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
      configurationLimit = 1;
    };
    growPartition = true;
    kernelParams = ["net.ifnames=0"];
  };

  # Service state, including /var/lib/comin, lives on the persistent root.
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      autoResize = true;
    };
    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };
  };
  virtualisation.diskSize = 24 * 1024;

  users.users.tm = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZMIGNBlZ+VX528eFfwCmEuN4oQCigRA+FPwADzixds trent@muninn"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII6sEj9jzEpu4Cbko4lLq54i16hM4RyIFmaIM5uZ2RH8 trent@huginn"
    ];
  };
  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

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

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    extra-substituters = ["https://cache.numtide.com"];
    extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
    trusted-users = ["@wheel"];
  };

  programs = {
    zsh.enable = true;
    nh.enable = true;
    nix-index-database.comma.enable = true;
    nix-ld = {
      enable = true;
      libraries = [pkgs.stdenv.cc.cc.lib];
    };
  };

  environment.systemPackages = with pkgs; [
    btop
    curl
    deadnix
    gcc
    git
    gnumake
    just
    nix-diff
    nix-init
    nix-output-monitor
    nix-search-tv
    nix-tree
    nix-update
    nurl
    openssh
    openssl
    pkg-config
    tree
    unzip
    wget
  ];

  services.comin = {
    enable = true;
    remotes = [
      {
        name = "origin";
        url = "https://github.com/trent-maetzold/dotfiles.git";
        branches.main = {
          name = "staging";
          operation = "switch";
        };
      }
    ];
  };
}
