{ lib, buildNpmPackage, fetchurl, jq, python3 }:

# The npm tarball ships a prebuilt dist/. devDependencies and scripts are
# stripped so package-lock.json covers runtime deps only and nothing is built
# beyond native addons (better-sqlite3, compiled by `npm rebuild`).
#
# To update: bump version + hash, then regenerate package-lock.json from the
# new tarball's package.json with devDependencies/scripts removed:
#   npm install --package-lock-only --ignore-scripts
# and refresh npmDepsHash.
buildNpmPackage rec {
  pname = "openwiki";
  version = "0.9.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/openwiki/-/openwiki-${version}.tgz";
    hash = "sha512-ARArQcKjvBWD56cAl0L5SGNmPfrE957zTPVvY+Hi1wVqBg7FqWWeqquPA4+fkA+iHAWclCScD9Snu7jUB9DCHw==";
  };

  # jq by store path: npmDeps also runs postPatch, without nativeBuildInputs.
  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies, .scripts)' package.json > package.json.new
    mv package.json.new package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-4/sM9o70RtH5iunww6/DQaQEwY0mZmNKU8vtjfWI9RY=";
  dontNpmBuild = true;
  nativeBuildInputs = [ python3 ]; # node-gyp for better-sqlite3

  meta = {
    description = "LangChain OpenWiki CLI";
    homepage = "https://github.com/langchain-ai/openwiki";
    license = lib.licenses.mit;
    mainProgram = "openwiki";
  };
}
