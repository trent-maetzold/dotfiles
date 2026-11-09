{ lib, buildNpmPackage, fetchurl, jq }:

# Prebuilt npm tarball; same update recipe as ../openwiki/default.nix.
buildNpmPackage rec {
  pname = "confluence-cli";
  version = "2.31.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/confluence-cli/-/confluence-cli-${version}.tgz";
    hash = "sha512-LpyhbQJkN1Wz+8k5TtPIRSKolUWSoIhwqJHyvUW8K9XE5EaWn1S9cca7W56l9lId9X8aegTSeEDCrCZgLv7ckQ==";
  };

  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies, .scripts)' package.json > package.json.new
    mv package.json.new package.json
    rm -f npm-shrinkwrap.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-j8b+0gskhp9RYKrg0dH7U5lHooKmJdgi9g46jNNdzkA=";
  dontNpmBuild = true;

  meta = {
    description = "Confluence CLI";
    homepage = "https://github.com/pchuri/confluence-cli";
    license = lib.licenses.mit;
    mainProgram = "confluence";
  };
}
