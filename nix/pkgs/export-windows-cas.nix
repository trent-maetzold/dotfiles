{ writeShellApplication, coreutils }:
writeShellApplication {
  name = "export-windows-cas";
  runtimeInputs = [ coreutils ];
  text = ''
    if [[ "$#" -ne 1 || "$1" == "--help" || "$1" == "-h" ]]; then
      echo "Usage: export-windows-cas OUTPUT.pem"
      echo "Run inside WSL. Exports Windows Root and intermediate CA stores."
      [[ "$#" -eq 1 && ( "$1" == "--help" || "$1" == "-h" ) ]]
      exit
    fi
    command -v wslpath >/dev/null || { echo "This command requires WSL." >&2; exit 1; }
    powershell="$(command -v powershell.exe || true)"
    if [[ -z "$powershell" ]]; then
      powershell="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
    fi
    [[ -x "$powershell" ]] || { echo "Windows PowerShell not found." >&2; exit 1; }
    destination="$(realpath -m -- "$1")"
    temporary="$(mktemp -- "$destination.XXXXXX")"
    trap 'rm -f -- "$temporary"' EXIT
    "$powershell" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass \
      -File "$(wslpath -w ${./export-windows-cas.ps1})" > "$temporary"
    [[ -s "$temporary" ]] || { echo "Windows returned an empty CA bundle." >&2; exit 1; }
    mv -- "$temporary" "$destination"
    echo "Saved Windows CA bundle to $destination" >&2
  '';
}
