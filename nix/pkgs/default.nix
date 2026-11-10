# Local packages as an overlay (pkgs.<name>). When nixpkgs gains one, delete its line.
{
  uv2nix,
  pyproject-nix,
  pyproject-build-systems,
}: final: prev: {
  confluence-cli = final.callPackage ./confluence-cli {};
  deepwiki-cli = final.callPackage ./deepwiki-cli {};
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
