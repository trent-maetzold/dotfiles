{
  pkgs,
  app,
}:
# The Windows half (windows-cas.py) runs under uv.exe from the same folder.
app "Export the Windows CAs (WSL) to a PEM bundle" (pkgs.writeShellApplication {
  name = "import-windows-ca";
  runtimeInputs = [pkgs.uv];
  text = ''exec uv run --quiet --script ${./.}/import-windows-ca "$@"'';
})
