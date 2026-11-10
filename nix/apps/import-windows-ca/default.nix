# The Windows half (windows-cas.py) runs under uv.exe, so the whole folder goes
# to the store to keep it beside the script. wslpath and uv.exe come from
# WSL/Windows, not Nix, so they can't be runtimeInputs.
{
  pkgs,
  app,
}:
app "Export the Windows CAs (WSL) to a PEM bundle" (pkgs.lib.getExe (pkgs.writeShellApplication {
  name = "import-windows-ca";
  runtimeInputs = [pkgs.uv];
  text = ''exec ${./.}/import-windows-ca.py "$@"'';
}))
