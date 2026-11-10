# Local packages as an overlay (pkgs.<name>). When nixpkgs gains one, delete its line.
{
  bkt,
  uv2nix,
  pyproject-nix,
  pyproject-build-systems,
}: final: prev: {
  # Wrap a package so it reads secrets from files at launch; see ../lib/with-secrets.nix.
  withSecrets = import ../lib/with-secrets.nix final;
  bkt = bkt.packages.${final.stdenv.hostPlatform.system}.bkt;
  confluence-cli = final.callPackage ./confluence-cli {};
  deepwiki-cli = final.callPackage ./deepwiki-cli {};
  magpie-cli = final.callPackage ./magpie-cli {};
  openwiki-cli = final.callPackage ./openwiki-cli {};
  tredis = final.callPackage ./tredis {};
  secrets-env = final.callPackage ./secrets-env {};
  outlook-cli = final.callPackage ./outlook-cli {};
  inherit
    (final.callPackage ./keeper-cli {inherit uv2nix pyproject-nix pyproject-build-systems;})
    keeper-commander
    keeper-secrets-manager-cli
    keeper-secrets
    ;
}
