{
  pkgs,
  app,
}:
app "Export the Windows CAs (WSL) to a PEM bundle" (pkgs.writeShellApplication {
  name = "import-windows-ca";
  runtimeEnv.PS1_SCRIPT = ./import-windows-ca.ps1;
  text = builtins.readFile ./import-windows-ca.sh;
})
