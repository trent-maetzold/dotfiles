# Keeper vault fields -> files under /run/keeper-secrets; run by the
# keeper-secrets NixOS module (../../nixos/keeper-secrets.nix).
{
  venv,
  writeShellApplication,
  util-linux,
  jq,
  getent,
}:
writeShellApplication {
  name = "keeper-secrets";
  runtimeInputs = [util-linux jq getent];
  runtimeEnv = {
    PYTHON = "${venv}/bin/python";
    FETCH = ./fetch.py;
  };
  text = builtins.readFile ./keeper-secrets.sh;
}
