{
  inputs,
  config,
  ...
}: let
  inherit (inputs) nixpkgs home-manager;
  identity = import ../../users/trent/_identity.nix;
in {
  flake.modules.nixos.muninn = let
    nixos = config.flake.modules.nixos;
  in
    # muninn: trent's encrypted ephemeral-root laptop with Umbriel. The flake adds
    # Home Manager for Trent.
    {
      inputs,
      pkgs,
      ...
    }: {
      imports = [
        nixos.trent
        nixos.machineProfile
        nixos.umbriel
        nixos.noctalia
        nixos.noctalia-greeter
        nixos.fonts
        "${inputs.nixos-hardware}/common/cpu/intel/meteor-lake"
        "${inputs.nixos-hardware}/common/gpu/nvidia/ada-lovelace"
        "${inputs.nixos-hardware}/common/pc/laptop"
        "${inputs.nixos-hardware}/common/pc/ssd"
        nixos.nvidia-prime
        nixos.quadlet
        nixos.citrix
      ];

      networking.hostName = "muninn";

      # Enroll once with: sudo tailscale up --login-server=https://hs.trkm.io
      services.tailscale.enable = true;
      users.users.trent = {
        uid = 1000;
        extraGroups = ["networkmanager"];
        shell = pkgs.nushell;
        # Start the systemd --user manager, and so the magpie gateway service
        # at boot so agents reached over SSH have the gateway before anyone logs in.
        # Same as `sudo loginctl enable-linger trent`.
        linger = true;
      };
      # Unlock applications' saved logins when the desktop session starts.
      services.gnome.gnome-keyring.enable = true;
      # Global UI scale for the laptop panel. Preserve the greeter state across reboots.
      services.displayManager.noctalia-greeter.settings.output.scale = 1.4;
      preservation.preserveAt."/persist".directories = [
        {
          directory = "/var/lib/noctalia-greeter";
          user = "greeter";
          group = "greeter";
          mode = "0750";
        }
        "/var/lib/tailscale"
      ];
      hardware.facter.reportPath = ./facter.json;
      # Intel Arc (Meteor Lake) and RTX 4050 Laptop, from facter.json.
      hardware.nvidia.prime = {
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:86:0:0";
      };
      system.stateVersion = "26.11";
    };
  flake.nixosConfigurations.muninn = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
      user = identity;
    };
    modules = [
      config.flake.modules.nixos.muninn
      home-manager.nixosModules.home-manager
      {
        nixpkgs.overlays = [inputs.zoldt-pkgs.modules.overlays.default];
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = inputs;
          users.trent.imports = with config.flake.modules.homeManager; [
            defaultProfile
            desktopProfile
            desktop-magpie
            umbriel
            noctalia
            trent
            muninn
          ];
        };
      }
    ];
  };
}
