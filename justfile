# Tasks for this repo. Each recipe wraps a flake app (nix/apps), so host flakes
# can run the same tasks with `nix run`.

default:
    @just --list

# Refresh secrets.yaml in DIR from the Keeper/rbw sources in DIR/secrets.sources.
sync-secrets dir:
    nix run .#sync-secrets -- {{dir}}

# Export Windows Root/intermediate CAs (WSL) to a PEM bundle.
import-windows-ca out:
    nix run .#import-windows-ca -- {{out}}
