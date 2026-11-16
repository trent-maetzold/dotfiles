# oh-my-zsh's git plugin aliases, from nu_scripts' nushell port (nushell-only:
# some aliases call nushell functions). jj is used as is, without aliases.
{lib, ...}: {
  # After nushell.nix's NU_LIB_DIRS, which points `use` at nu_scripts.
  programs.nushell.extraConfig = lib.mkAfter ''
    use aliases/git/git-aliases.nu *
  '';
}
