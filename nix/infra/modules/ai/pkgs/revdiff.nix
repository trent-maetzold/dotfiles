# revdiff from its flake.
{revdiff, ...}: {
  flake.overlays.revdiff = final: _: {revdiff = revdiff.packages.${final.stdenv.hostPlatform.system}.default;};
}
