# muninn: trent's encrypted ephemeral-root laptop with Umbriel. The flake adds
# Home Manager and ./home.nix for trent.
{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    (inputs.import-tree ../../modules/nixos/machine)
    ../../modules/nixos/desktop/umbriel
    ../../modules/nixos/desktop/fonts.nix
    "${inputs.nixos-hardware}/common/cpu/intel/meteor-lake"
    "${inputs.nixos-hardware}/common/gpu/nvidia/ada-lovelace"
    "${inputs.nixos-hardware}/common/pc/laptop"
    "${inputs.nixos-hardware}/common/pc/ssd"
    ../../modules/nixos/hardware/nvidia-prime.nix
    ../../modules/nixos/services/quadlet.nix
    ./citrix.nix
    inputs.sops-nix.nixosModules.sops
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

  # Secrets decrypt into /run/secrets (tmpfs) on every boot; the age key is
  # the ssh-ed25519 host key that the /etc overlay already persists. See
  # .sops.yaml beside secrets.yaml for the recipients.
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    };
    gnupg.sshKeyPaths = [];
    secrets."hermes-desktop-token" = {
      key = "hermes/desktop-token";
      owner = "trent";
      mode = "0400";
    };
  };
}
