# Keeper vault fields -> files under /run/keeper-secrets; run by the
# keeper-secrets NixOS module (../../modules/nixos/keeper-secrets.nix).
{
  venv,
  symlinkJoin,
  writeShellApplication,
  util-linux,
  jq,
  getent,
}:
symlinkJoin {
  name = "keeper-secrets";
  meta.mainProgram = "keeper-secrets";
  paths = [
    (writeShellApplication {
      name = "keeper-secrets";
      runtimeInputs = [util-linux jq getent];
      runtimeEnv = {
        PYTHON = "${venv}/bin/python";
        FETCH = ./fetch.py;
      };
      text = builtins.readFile ./keeper-secrets.sh;
    })
    # Interactive Keeper login (as you, in a terminal) that fetches resume from.
    (writeShellApplication {
      name = "keeper-secrets-login";
      text = ''KEEPER_CONFIG_STORAGE="file" exec ${venv}/bin/python ${./fetch.py}'';
    })
  ];
}
