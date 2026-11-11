# muninn: the encrypted ephemeral-root laptop. The flake adds Home Manager and
# ./home.nix for trent.
{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.preservation.nixosModules.default
    ./configuration.nix
    ./desktop.nix
    ./disko.nix
  ];

  # Lets rootless Podman quadlets (dotfiles' quadlet-nix) run as user units.
  systemd.user.generators.podman-user-generator = "${pkgs.podman}/lib/systemd/user-generators/podman-user-generator";
}
