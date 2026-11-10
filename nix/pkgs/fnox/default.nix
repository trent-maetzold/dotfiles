# shortcut: release binary because nixpkgs' fnox fails to build (aws-lc-sys); switch to pkgs.fnox when it builds.
{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fnox";
  version = "1.48.0";
  src = fetchurl {
    url = "https://github.com/jdx/fnox/releases/download/v${finalAttrs.version}/fnox-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-2dopRz6Uo7nztlEJZXxpgNaix8b6WeEHA9xbcTpdnOc=";
  };
  sourceRoot = ".";
  installPhase = "install -Dm755 fnox $out/bin/fnox";
  meta = {
    description = "Encrypted and remote secret manager";
    homepage = "https://github.com/jdx/fnox";
    license = lib.licenses.mit;
    mainProgram = "fnox";
    platforms = ["x86_64-linux"];
  };
})
