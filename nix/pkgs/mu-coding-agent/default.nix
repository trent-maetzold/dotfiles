# mu (github:qybaihe/MU): pi plus a small "judge" model for yes/no calls.
# shortcut: from the npm release; the repo's flake fails (`attribute 'integrity'
# missing` in its lockfile), switch to it once it builds.
{
  lib,
  stdenv,
  autoPatchelfHook,
  libxcb,
  fetchurl,
  makeWrapper,
  nodejs_22,
  fd,
  ripgrep,
}: let
  npm = name: version: hash:
    fetchurl {
      url = "https://registry.npmjs.org/${name}/-/${baseNameOf name}-${version}.tgz";
      inherit hash;
    };
  deps = {
    "jiti" = npm "jiti" "2.7.0" "sha512-AC/7JofJvZGrrneWNaEnJeOLUx+JlGt7tNa0wZiRPT4MY1wmfKjt2+6O2p2uz2+skll8OZZmJMNqeke7kKbNgQ==";
    "@silvia-odwyer/photon-node" = npm "@silvia-odwyer/photon-node" "0.3.4" "sha512-bnly4BKB3KDTFxrUIcgCLbaeVVS8lrAkri1pEzskpmxu9MdfGQTy8b8EgcD83ywD3RPMsIulY8xJH5Awa+t9fA==";
  };
in
  stdenv.mkDerivation rec {
    pname = "mu-coding-agent";
    version = "0.3.11";
    src = npm "mu-agent" version "sha512-i1lLjwffPN1Mf79zUYV4ZulM/w4DSaRL92RCIXvc3g8L8BZlpw8o3UdPtEwGbJEbLI4Jm9tYmgKACaEo0OvClw==";

    nativeBuildInputs = [makeWrapper autoPatchelfHook];
    # Clipboard addon (linux-platform-x11.node).
    buildInputs = [stdenv.cc.cc.lib libxcb];
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/mu
      cp -R . $out/lib/mu
      ${lib.concatStrings (lib.mapAttrsToList (name: tgz: ''
          mkdir -p $out/lib/mu/node_modules/${name}
          tar xzf ${tgz} --strip-components=1 -C $out/lib/mu/node_modules/${name}
        '')
        deps)}
      makeWrapper ${nodejs_22}/bin/node $out/bin/mu \
        --add-flags $out/lib/mu/kyrn/bin/mu.mjs \
        --suffix PATH : ${lib.makeBinPath [nodejs_22]} \
        --prefix PATH : ${lib.makeBinPath [fd ripgrep]}
      runHook postInstall
    '';

    meta = {
      description = "Coding agent built on pi that hands yes/no calls to a small judge model";
      homepage = "https://github.com/qybaihe/MU";
      license = lib.licenses.mit;
      mainProgram = "mu";
    };
  }
