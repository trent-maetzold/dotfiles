# `nx PKG... [-- CMD ARGS...]`: run packages that aren't installed, via `nix shell`.
{
  flake.overlays.nx = final: _: {
    nx = final.writeShellScriptBin "nx" ''
      pkgs=()
      while [ $# -gt 0 ] && [ "$1" != -- ]; do pkgs+=("nixpkgs#$1"); shift; done
      [ ''${#pkgs[@]} -gt 0 ] || { echo "usage: nx PKG... [-- CMD ARGS...]" >&2; exit 1; }
      if [ "''${1:-}" = -- ]; then
        shift
        exec nix shell "''${pkgs[@]}" -c "$@"
      fi
      exec nix shell "''${pkgs[@]}"
    '';
  };
}
