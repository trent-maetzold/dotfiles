# Nix itself: flakes and nix-ld for unpatched binaries and Python wheels. nh is
# in Home Manager (home/system/nix.nix).
{
  options,
  pkgs,
  ...
}: {
  nix.enable = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  # Binary cache for github:numtide/llm-agents.nix (home/ai).
  nix.settings.extra-substituters = ["https://cache.numtide.com"];
  nix.settings.extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];

  programs.nix-ld.enable = true;
  # Keep the NixOS defaults; add what pip/uv wheels and source builds need.
  programs.nix-ld.libraries =
    options.programs.nix-ld.libraries.default
    ++ (with pkgs; [
      stdenv.cc.cc.lib
      libpq # psycopg2
      krb5.lib # gssapi
    ]);
  # Headers/config tools for building psycopg2 and gssapi from source.
  environment.systemPackages = with pkgs; [libpq.pg_config krb5.dev];
}
