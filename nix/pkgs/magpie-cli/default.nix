{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
stdenv.mkDerivation {
  pname = "magpie-cli";
  version = "0.1.3419";

  src = fetchurl {
    url = "https://usemagpie.ai/files/v0.1.3419/magpie-cli-linux-amd64";
    sha256 = "83f47ff506b1ddbc4de2d4faf789735881a221940a40a6fb4491e4f5bcba1789";
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
