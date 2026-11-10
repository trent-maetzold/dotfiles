# Tasks for this repo. Each recipe wraps a flake app (nix/apps), so host flakes
# can run the same tasks with `nix run`.

default:
    @just --list

# Log in to Keeper if needed, then nh os switch (args go to nh).
switch *args:
    nix run .#switch -- {{args}}

# Export Windows Root/intermediate CAs (WSL) to a PEM bundle.
import-windows-ca out:
    nix run .#import-windows-ca -- {{out}}
