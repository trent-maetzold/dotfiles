{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}: let
  hashes = builtins.fromJSON (builtins.readFile ./hashes.json);
in
  stdenv.mkDerivation {
    pname = "magpie-cli";
    inherit (hashes) version;

    src = fetchurl {
      url = "https://usemagpie.ai/files/v${hashes.version}/magpie-cli-linux-amd64";
      hash = hashes.cli;
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
