# billion-context pi extension, straight from npm. Its dist is bundled (zod included).
# shortcut: mysql2 (dynamic import, MySQL storage only) is not shipped; add it if that backend is used.
{
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "billion-context";
  version = "0.1.213";
  src = fetchurl {
    url = "https://registry.npmjs.org/billion-context/-/billion-context-${version}.tgz";
    hash = "sha256-49q0fJ4su+Z7VBGQGIoyF1ccEMs+p3GrfASxMBJR35g=";
  };
  installPhase = "cp -r . $out";
}
