# muninn: trent's encrypted ephemeral-root laptop with Niri. The flake adds
# Home Manager and ./home.nix for trent.
{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    (inputs.import-tree ../../modules/nixos/machine)
    ../../modules/nixos/desktop/niri
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
  users.users.trent = {
    uid = 1000;
    shell = pkgs.nushell;
  };
  hardware.facter.reportPath = ./facter.json;
  # Intel Arc (Meteor Lake) and RTX 4050 Laptop, from facter.json.
  hardware.nvidia.prime = {
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:86:0:0";
  };
  # Match Niri's 1.5 on the internal panel; overrides the synced scale.
  services.displayManager.noctalia-greeter.settings.output.scales = "eDP-1:1.5";
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
