{ lib, buildNpmPackage, fetchurl, jq }:

# Prebuilt npm tarball; same update recipe as ../openwiki/default.nix.
buildNpmPackage rec {
  pname = "ctx7";
  version = "0.11.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/ctx7/-/ctx7-${version}.tgz";
    hash = "sha512-ZMzlNA+WzCoQ2BnmYusVj8iwL+GBuAzKk/3D7182HPNBjBezYi5moNkQ9bOaGvLzhNmjdlsnM24fAE1EiXW3rA==";
  };

  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies, .scripts)' package.json > package.json.new
    mv package.json.new package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-BSfiBkQDqX1DK54gXbpsN0d5xrirJj+VpkmBZbhpa/s=";
  dontNpmBuild = true;

  meta = {
    description = "Context7 CLI: up-to-date library docs for agents";
    homepage = "https://context7.com";
    license = lib.licenses.mit;
    mainProgram = "ctx7";
  };
}
