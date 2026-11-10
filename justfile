# Tasks for this repo. Flake apps get a recipe here too (`nix run .#<app>`).

default:
    @just --list

# Export Windows Root/intermediate CAs (WSL) to a PEM bundle, default: the nixos flake's certs.
import-windows-ca out=(env("HOME") / ".config/nixos/nix/certs/windows-ca.pem"):
    #!/usr/bin/env bash
    set -euo pipefail
    ps="$(command -v powershell.exe || echo /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe)"
    dest="$(realpath -m -- "{{out}}")"
    tmp="$(mktemp -- "$dest.XXXXXX")"
    trap 'rm -f -- "$tmp"' EXIT
    "$ps" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass \
      -File "$(wslpath -w "{{justfile_directory()}}/scripts/import-windows-ca.ps1")" > "$tmp"
    [[ -s "$tmp" ]] || { echo "Windows returned an empty CA bundle." >&2; exit 1; }
    mv -- "$tmp" "$dest"
    echo "Saved Windows CA bundle to $dest" >&2
