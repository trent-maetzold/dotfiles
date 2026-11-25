# Stage value-only SOPS files for systemd and Quadlet without exposing them to Nix.
{
  lib,
  pkgs,
}: name: vars: {
  file = "/run/${name}.env";
  ExecStartPre = [
    "+${pkgs.writeShellScript "${name}-env" ''
      umask 077
      {
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (var: file: ''printf '%s=%s\n' ${var} "$(<${file})"'') vars)}
      } > /run/${name}.env
    ''}"
  ];
}
