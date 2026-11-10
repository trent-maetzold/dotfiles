# Tasks for this repo. Each recipe wraps a flake app (nix/apps), so host flakes
# can run the same tasks with `nix run`.

default:
    @just --list

# Update the host flake's inputs (programs.nh.flake), then switch (args go to nh).
switch *args:
    nix run .#switch -- {{args}}

# Export Windows Root/intermediate CAs (WSL) to a PEM bundle (--output-file, or IMPORT_WIN_CA_OUTPUT_FILE).
import-win-ca *args:
    nix run .#import-win-ca -- {{args}}
