{config, ...}: let
  commonNix = config.flake.modules.nixos.nix;
in {
  flake.modules.nixos.machine-base =
    # Standalone (non-WSL) machines: boot, network, nix.
    {
      lib,
      pkgs,
      ...
    }: {
      imports = [commonNix];

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

      # Weekly cleanup of every profile (system, Home Manager, user) and stale GC
      # roots, keeping the last 5 generations and anything from the last two weeks.
      # nh's CLI and NH_FLAKE come from Home Manager (home/system/nix.nix).
      programs.nh = {
        enable = true;
        clean = {
          enable = true;
          extraArgs = "--keep 5 --keep-since 14d";
        };
      };
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
}
