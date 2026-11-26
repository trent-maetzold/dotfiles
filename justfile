# Tasks for this repo. Each recipe wraps a flake app (modules/apps), also runnable
# with `nix run .#<app>`.

default:
    @just --list

# Update this flake's inputs, commit flake.lock, then switch (args go to nh).
switch *args:
    nix run .#switch -- {{args}}

# Export Windows Root/intermediate CAs (WSL) to a PEM bundle (--output-file, or IMPORT_WIN_CA_OUTPUT_FILE).
import-win-ca *args:
    nix run .#import-win-ca -- {{args}}

# Apply a host config here (live USB), or on a remote machine: bootstrap <host> [address].
bootstrap *args:
    nix run .#bootstrap -- {{args}}
