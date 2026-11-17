{
  infra,
  pkgs,
  ...
}: {
  imports = [
    infra.hosts.frigg.nixosModule
    ../../modules/nixos/deploy/comin-staging.nix
  ];

  # Do not add a Cinnamon app introduced only by the nixpkgs pin change.
  environment.cinnamon.excludePackages = [pkgs.superlight];
}
