# Tasks for this repo. Each recipe wraps a flake app (nix/apps), so host flakes
# can run the same tasks with `nix run`.

default:
    @just --list

# Update the host flake's inputs (programs.nh.flake), then switch (args go to nh).
switch *args:
    nix run .#switch -- {{args}}

# Copy Keeper/rbw sources into a sops file (--if/--of, or SYNC_SECRETS_IF/_OF).
sync-secrets *args:
    nix run .#sync-secrets -- {{args}}

# Export Windows Root/intermediate CAs (WSL) to a PEM bundle (--of, or IMPORT_WINDOWS_CA_OF).
import-windows-ca *args:
    nix run .#import-windows-ca -- {{args}}
