{
  flake.modules.homeManager.carapace =
    # Completions for external commands in every enabled shell (nushell included,
    # as its external completer). Covers git, nix, jj, nh, kubectl, podman, gh, ...
    {
      programs.carapace.enable = true;
    };
}
