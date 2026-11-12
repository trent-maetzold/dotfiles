{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
stdenv.mkDerivation rec {
  pname = "magpie-cli";
  version = "0.1.3940";

  src = fetchurl {
    url = "https://github.com/yetone/magpie/releases/download/v${version}/magpie-cli-linux-amd64";
    hash = "sha256-D0D69qHOxynmmyiWirPvlEC99Xk8uRJN3sevYGx526A=";
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
