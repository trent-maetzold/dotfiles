# Per-directory environments: `use flake` in .envrc, cached by nix-direnv.
# Secrets come from the devShell's shellHook (lib.mkSecretsShell).
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global.hide_env_diff = true;
  };
}
