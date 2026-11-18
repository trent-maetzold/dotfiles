{
  config,
  inputs,
  pkgs,
  user,
  ...
}: {
  imports = [
    ./storage.nix
    ./mimir.nix
    ./hermes.nix
    ./containers.nix
    ./paseo.nix
    inputs.comin.nixosModules.comin
    inputs.sops-nix.nixosModules.sops
  ];

  nixpkgs.overlays = [inputs.self.overlays.default];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = inputs // {inherit user;};
    users.tm = import ./home.nix;
  };

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.11";
  hardware.facter.reportPath = ./facter.json;

  # Headless: a failed unit must not isolate into a locked emergency shell.
  systemd.enableEmergencyMode = false;
  boot = {
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    loader.efi.efiSysMountPoint = "/boot/efi";
    zfs.forceImportRoot = true;
  };

  networking = {
    hostName = "yggdrasil";
    hostId = "6d8a7c3f";
    bonds.bond0.interfaces = ["eno1" "eno2" "eno3" "eno4"];
    bridges.br0.interfaces = ["bond0"];
    interfaces.br0.ipv4.addresses = [
      {
        address = "10.10.20.10";
        prefixLength = 24;
      }
    ];
    defaultGateway = "10.10.20.1";
    nameservers = ["10.10.20.1" "1.1.1.1"];
    firewall.trustedInterfaces = ["tailscale0"];
    nat = {
      enable = true;
      internalInterfaces = ["tailscale0"];
      externalInterface = "br0";
    };
  };

  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets.ts-authkey.path;
    useRoutingFeatures = "server";
    extraUpFlags = ["--login-server=https://hs.trkm.io"];
    extraSetFlags = ["--netfilter-mode=off" "--accept-routes" "--advertise-routes=10.10.20.154/32"];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  programs.zsh.enable = true;
  users.users.tm = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZMIGNBlZ+VX528eFfwCmEuN4oQCigRA+FPwADzixds trent@muninn"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII6sEj9jzEpu4Cbko4lLq54i16hM4RyIFmaIM5uZ2RH8 trent@huginn"
    ];
  };
  security.sudo.wheelNeedsPassword = false;

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  environment.systemPackages = with pkgs; [curl git];
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    extra-substituters = ["https://cache.numtide.com"];
    extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
    trusted-users = ["@wheel"];
  };
  programs.nix-ld = {
    enable = true;
    libraries = [pkgs.stdenv.cc.cc.lib];
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age = {
      keyFile = "/var/lib/age/key.txt";
      sshKeyPaths = [];
    };
    gnupg.sshKeyPaths = [];
    secrets.ts-authkey.key = "tailscale/ts-authkey";
  };

  services.comin = {
    enable = true;
    remotes = [
      {
        name = "origin";
        url = "https://github.com/trent-maetzold/dotfiles.git";
        branches.main = {
          name = "main";
          operation = "switch";
        };
      }
    ];
  };
}
