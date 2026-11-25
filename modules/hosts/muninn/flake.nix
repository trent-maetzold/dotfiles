{
  inputs,
  config,
  ...
}: let
  inherit (inputs) self nixpkgs home-manager;
  trent = import ../../users/trent/_identity.nix;
in {
  flake.modules.nixos.muninn = let
    nixos = config.flake.modules.nixos;
  in
    # muninn: trent's encrypted ephemeral-root laptop with Umbriel. The flake adds
    # Home Manager and ./_home.nix for trent.
    {
      inputs,
      pkgs,
      ...
    }: {
      imports = [
        nixos.machineProfile
        nixos.umbriel
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
      preservation.preserveAt."/persist".directories = ["/var/lib/tailscale"];
      users.users.trent = {
        uid = 1000;
        shell = pkgs.nushell;
        # Start the systemd --user manager, and so the magpie gateway service
        # (nix/modules/home/desktop/magpie.nix), at boot rather than at the first
        # login: agents reached over SSH need the gateway before anyone logs in.
        # Same as `sudo loginctl enable-linger trent`.
        linger = true;
      };
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
      user = trent;
    };
    modules = [
      config.flake.modules.nixos.muninn
      home-manager.nixosModules.home-manager
      {
        nixpkgs.overlays = [self.overlays.default];
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = inputs // {user = trent;};
          users.trent.imports = [config.flake.modules.homeManager.defaultProfile config.flake.modules.homeManager.desktopProfile config.flake.modules.homeManager.trent config.flake.modules.homeManager.muninn];
        };
      }
    ];
  };
}
