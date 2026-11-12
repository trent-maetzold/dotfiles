{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
stdenv.mkDerivation rec {
  pname = "magpie-cli";
  version = "0.1.3951";

  src = fetchurl {
    url = "https://github.com/yetone/magpie/releases/download/v${version}/magpie-cli-linux-amd64";
    hash = "sha256-Rlfew50pHGjJormVVrB7MOt0V1B5S/OW29vIuoT2oec=";
  };

  dontUnpack = true;
  nativeBuildInputs = [autoPatchelfHook];
  buildInputs = [stdenv.cc.cc.lib];
  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/magpie"
    runHook postInstall
  '';

  meta = {
    description = "Magpie terminal-only model gateway";
    homepage = "https://github.com/yetone/magpie";
    license = lib.licenses.mit;
    platforms = ["x86_64-linux"];
    mainProgram = "magpie";
  };
}
