{ lib, buildNpmPackage, fetchurl, jq }:

# Prebuilt npm tarball; same update recipe as ../openwiki-cli/default.nix.
buildNpmPackage rec {
  pname = "deepwiki";
  version = "0.1.8";

  src = fetchurl {
    url = "https://registry.npmjs.org/@seflless/deepwiki/-/deepwiki-${version}.tgz";
    hash = "sha512-T6b9PunS+1sSMAtyHih9pao27Exo/5qsOQ+BIVfNOnI/fV33p1PdPT1MCJni2aF1DApnIFfMaRVTLP4Ey0AaqQ==";
  };

  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies, .scripts)' package.json > package.json.new
    mv package.json.new package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-6ujv2Fsy7AmgDV0lnR5PmIT9iQu2b+/8gIgfxpeIQzo=";
  dontNpmBuild = true;

  meta = {
    description = "DeepWiki CLI: query DeepWiki docs for GitHub repos";
    homepage = "https://deepwiki.sh";
    license = lib.licenses.mit;
    mainProgram = "deepwiki";
  };
}
