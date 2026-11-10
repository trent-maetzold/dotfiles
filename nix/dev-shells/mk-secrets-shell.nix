# pkgs.mkShell whose shellHook fetches secrets on entry (nix develop, direnv
# `use flake`). Only the references reach the store; values exist only in the
# shell's environment. A failed lookup warns and the shell opens without them.
#
#   devShells.default = dotfiles.lib.mkSecretsShell pkgs {
#     packages = [pkgs.uv];
#     secrets = ./.env.secrets;  # or {DB_PW = "ksm:keeper://<uid>/field/password";}
#   };
pkgs: {
  secrets,
  shellHook ? "",
  ...
} @ args: let
  inherit (pkgs) lib;
  file =
    if builtins.isAttrs secrets
    then pkgs.writeText "env-secrets" (lib.concatStrings (lib.mapAttrsToList (n: v: "${n}=${v}\n") secrets))
    else secrets;
  secrets-env = pkgs.callPackage ../pkgs/secrets-env {};
in
  pkgs.mkShell (removeAttrs args ["secrets"]
    // {
      shellHook = ''
        if __secrets=$(${lib.getExe secrets-env} ${file}); then
          eval "$__secrets"
        else
          echo "devShell: secrets not loaded; unlock the vault and re-enter." >&2
        fi
        unset __secrets
        ${shellHook}
      '';
    })
