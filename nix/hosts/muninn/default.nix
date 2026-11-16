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
    ../../modules/nixos/services/quadlet.nix
  ];

  networking.hostName = "muninn";
  users.users.trent.shell = pkgs.nushell;
  hardware.facter.reportPath = ./facter.json;
  # Match Niri's 1.5 on the internal panel; overrides the synced scale.
  services.displayManager.noctalia-greeter.settings.output.scales = "eDP-1:1.5";
  system.stateVersion = "26.11";
}
