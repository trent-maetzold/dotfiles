# Wrap every binary of `package` so it reads its secrets from files at launch,
# e.g. withSecrets pkgs.foo { FOO_TOKEN = config.sops.secrets.foo-token.path; }.
# The value reaches only that process, never argv or the Nix store; an
# unreadable file leaves any inherited value alone.
{ lib, symlinkJoin, makeWrapper }:
package: secrets:
symlinkJoin {
  name = "${package.name}-with-secrets";
  paths = [ package ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    for bin in $out/bin/*; do
      wrapProgram "$bin" ${lib.concatStringsSep " " (lib.mapAttrsToList (name: path:
        "--run ${lib.escapeShellArg ''if [ -r "${path}" ]; then export ${name}="$(< "${path}")"; fi''}") secrets)}
    done
  '';
  inherit (package) meta;
}
