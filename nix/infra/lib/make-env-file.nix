# Env file `/run/<name>.env` for a unit, written as root before it starts, from
# `{VAR = <value-only secret file>;}`: `file` and the unit's `ExecStartPre`.
{lib, ...}: {
  flake.lib.makeEnvFile = {
    pkgs,
    name,
    vars,
  }: {
    file = "/run/${name}.env";

    ExecStartPre = [
      "+${pkgs.writeShellScript "${name}-env" ''
        umask 077
        {
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList (var: file: ''printf '%s=%s\n' ${var} "$(<${file})"'') vars)}
        } > /run/${name}.env
      ''}"
    ];
  };
}
