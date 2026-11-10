# Keeper Commander (`keeper`) and Keeper Secrets Manager CLI (`ksm`) from uv.lock via uv2nix.
{
  lib,
  callPackage,
  python313,
  uv2nix,
  pyproject-nix,
  pyproject-build-systems,
}: let
  workspace = uv2nix.lib.workspace.loadWorkspace {workspaceRoot = ./.;};
  pythonSet =
    (callPackage pyproject-nix.build.packages {python = python313;}).overrideScope
    (lib.composeManyExtensions [
      pyproject-build-systems.overlays.wheel
      (workspace.mkPyprojectOverlay {sourcePreference = "wheel";})
      # The only sdist-only dependency; uv.lock doesn't record build systems.
      (final: prev: {
        jsonpath-rw = prev.jsonpath-rw.overrideAttrs (old: {
          nativeBuildInputs = old.nativeBuildInputs ++ final.resolveBuildSystem {setuptools = [];};
        });
      })
    ]);
  venv = pythonSet.mkVirtualEnv "keeper-env" workspace.deps.default;
  # Expose only each package's own scripts, not the venv's python.
  app = name: package:
    (callPackage pyproject-nix.build.util {}).mkApplication {inherit venv package;}
    // {meta.mainProgram = name;};
in {
  keeper-commander = app "keeper" pythonSet.keepercommander;
  keeper-secrets-manager-cli = app "ksm" pythonSet.keeper-secrets-manager-cli;
  keeper-secrets = callPackage ../keeper-secrets {inherit venv;};
}
