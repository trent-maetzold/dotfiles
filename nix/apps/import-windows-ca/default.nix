# Needs uv here and uv.exe on Windows, which runs windows-cas.py. The whole
# folder goes to the store, so windows-cas.py sits beside the script.
{app, ...}: app "Export the Windows CAs (WSL) to a PEM bundle" "${./.}/import-windows-ca.py"
