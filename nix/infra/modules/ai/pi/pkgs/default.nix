# pi extensions from npm, pinned in package-lock.json; `just pi-plugins` relocks it.
{config, ...}: {
  flake.overlays.pi-plugins = final: _: {
    pi-plugins = final.callPackage ({
      lib,
      stdenv,
      nodejs,
      importNpmLock,
      writeTextDir,
      # A consumer's own set needs its own lock, from `npm install --package-lock-only`.
      plugins ? config.pi.plugins,
      packageLock ? lib.importJSON ./package-lock.json,
    }: let
      package = {
        name = "pi-plugins";
        dependencies = lib.genAttrs plugins (_: "*");
      };
    in
      stdenv.mkDerivation (finalAttrs: {
        pname = "pi-plugins";
        version = "0";
        # npmConfigHook swaps this package.json for npmDeps' own.
        src = writeTextDir "package.json" (builtins.toJSON package);

        npmDeps = importNpmLock {inherit package packageLock;};
        # pi provides its own packages to extensions, so peers stay uninstalled, as with `pi install`.
        npmFlags = ["--legacy-peer-deps"];

        nativeBuildInputs = [nodejs importNpmLock.npmConfigHook];
        dontBuild = true;
        installPhase = "mkdir $out && cp -R node_modules $out";

        passthru = {
          inherit package;
          extensions = lib.genAttrs plugins (name: "${finalAttrs.finalPackage}/node_modules/${name}");
        };
      })) {};
  };

  perSystem = {pkgs, ...}: {
    packages = {inherit (pkgs) pi-plugins;};
  };
}
