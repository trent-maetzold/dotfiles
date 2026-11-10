{
  pkgs,
  app,
}:
# shortcut: libraries repeat the script's PEP 723 dependencies; keep them in sync.
app "Export the Windows CAs (WSL) to a PEM bundle" (pkgs.writers.writePython3Bin "import-windows-ca" {
  libraries = ps: with ps; [typer pydantic-settings cryptography];
  flakeIgnore = ["E501"];
  # The Windows half runs under uv.exe, so it must stay a separate file.
  makeWrapperArgs = ["--set-default" "WINDOWS_CAS_SCRIPT" "${./windows-cas.py}"];
} (builtins.readFile ./import-windows-ca.py))
