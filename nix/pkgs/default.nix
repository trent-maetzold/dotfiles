# Local packages as an overlay (pkgs.<name>). When nixpkgs gains one, delete its line.
{
  bkt,
  fnox,
  uv2nix,
  pyproject-nix,
  pyproject-build-systems,
}: final: prev: {
  # Wrap a package to run under `fnox exec`; see ../lib/with-fnox.nix.
  withFnox = import ../lib/with-fnox.nix final;
  bkt = bkt.packages.${final.stdenv.hostPlatform.system}.bkt;
  confluence-cli = final.callPackage ./confluence-cli {};
  deepwiki-cli = final.callPackage ./deepwiki-cli {};
  fnox = fnox.packages.${final.stdenv.hostPlatform.system}.default;
  magpie-cli = final.callPackage ./magpie-cli {};
  openwiki-cli = final.callPackage ./openwiki-cli {};
  tredis = final.callPackage ./tredis {};
  outlook-cli = final.callPackage ./outlook-cli {};
  inherit
    (final.callPackage ./keeper-cli {inherit uv2nix pyproject-nix pyproject-build-systems;})
    keeper-commander
    keeper-secrets-manager-cli
    ;
}
