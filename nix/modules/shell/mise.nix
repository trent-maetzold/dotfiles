# mise activates per project from mise.toml (tools and [env]), through its shell
# hook (nushell integration is on globally). Secrets: in mise.toml,
#   [env]
#   _.source = { path = "secrets.sh", redact = true }
# with secrets.sh: eval "$(secrets-env .env.secrets)"  (see nix/pkgs/secrets-env).
{pkgs, ...}: {
  programs.mise.enable = true;
  home.packages = [pkgs.secrets-env];
}
