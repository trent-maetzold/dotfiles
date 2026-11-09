{ lib, buildNpmPackage, fetchurl, jq }:

# The npm tarball ships a prebuilt, bundled dist/. Only the runtime deps
# (zod, mysql2, optional jimp) are installed; devDependencies and lifecycle
# scripts are stripped so package-lock.json stays small and nothing is built.
#
# To update: bump version + hash, then regenerate package-lock.json from the
# new tarball's package.json with devDependencies/scripts removed:
#   npm install --package-lock-only --ignore-scripts
# and refresh npmDepsHash.
buildNpmPackage rec {
  pname = "billion-context";
  version = "0.1.213";

  src = fetchurl {
    url = "https://registry.npmjs.org/billion-context/-/billion-context-${version}.tgz";
    hash = "sha512-27GMDHpqImsGev2Pw2JUyWImzJChggJVUqo6RNNeZ4CWFMnuKReQWFghOAZTBU05pmYho/2K0UZ7WWjQ+aBBWQ==";
  };

  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies, .scripts)' package.json > package.json.new
    mv package.json.new package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-r3rihYYcM5NpqM8dgi/TSWaqCzWr/vCQIDBQDVs+lf0=";
  dontNpmBuild = true;

  meta = {
    description = "Context-compression proxy and pi extension (bili)";
    homepage = "https://github.com/ranxianglei/billion-context";
    license = lib.licenses.mit;
    mainProgram = "bili";
  };
}
