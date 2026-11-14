# muninn: the encrypted ephemeral-root laptop. The flake adds Home Manager and
# ./home.nix for trent.
{pkgs, ...}: {
  imports = [
    ./configuration.nix
    ./desktop.nix
    ./disko.nix
    ./preservation.nix
    ./secrets.nix
  ];

  # Lets rootless Podman quadlets (dotfiles' quadlet-nix) run as user units.
  systemd.user.generators.podman-user-generator = "${pkgs.podman}/lib/systemd/user-generators/podman-user-generator";
}
