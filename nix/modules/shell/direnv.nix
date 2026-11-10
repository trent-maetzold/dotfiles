# Per-directory environments: `use flake` (cached by nix-direnv) and
# `use secrets` (use-secrets.sh) in .envrc.
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global.hide_env_diff = true;
    stdlib = builtins.readFile ./use-secrets.sh;
  };
}
