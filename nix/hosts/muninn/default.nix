# muninn: trent's encrypted ephemeral-root laptop with Niri. The flake adds
# Home Manager and ./home.nix for trent.
{inputs, ...}: {
  imports = [
    (inputs.import-tree ../../modules/nixos/machine)
    ../../modules/nixos/desktop/niri.nix
    ../../modules/nixos/desktop/fonts.nix
    ../../modules/nixos/services/quadlet.nix
  ];

  networking.hostName = "muninn";
  hardware.facter.reportPath = ./facter.json;
  system.stateVersion = "26.11";
}
