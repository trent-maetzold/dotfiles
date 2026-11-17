# colmena from its flake.
{colmena, ...}: {
  flake.overlays.colmena = colmena.overlays.default;
}
