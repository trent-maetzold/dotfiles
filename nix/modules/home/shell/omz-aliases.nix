# oh-my-zsh's git and jj plugin aliases.
# - git: nu_scripts' nushell port of the oh-my-zsh git plugin (nushell-only:
#   some aliases call nushell functions).
# - jj: oh-my-zsh 2026-08-16 plugins/jj, as shell-agnostic aliases (minus jjrt,
#   which needs zsh's $(...)).
{lib, ...}: {
  home.shellAliases = {
    jja = "jj abandon";
    jjb = "jj bookmark";
    jjba = "jj bookmark advance";
    jjbc = "jj bookmark create";
    jjbd = "jj bookmark delete";
    jjbf = "jj bookmark forget";
    jjbl = "jj bookmark list";
    jjbm = "jj bookmark move";
    jjbr = "jj bookmark rename";
    jjbs = "jj bookmark set";
    jjbt = "jj bookmark track";
    jjbu = "jj bookmark untrack";
    jjc = "jj commit";
    jjcmsg = "jj commit --message";
    jjd = "jj diff";
    jjdmsg = "jj desc --message";
    jjds = "jj desc";
    jje = "jj edit";
    jjgcl = "jj git clone";
    jjgf = "jj git fetch";
    jjgfa = "jj git fetch --all-remotes";
    jjgp = "jj git push";
    jjgpa = "jj git push --all";
    jjgpd = "jj git push --deleted";
    jjgpt = "jj git push --tracked";
    jjl = "jj log";
    jjla = "jj log -r \"all()\"";
    jjn = "jj new";
    jjnt = "jj new \"trunk()\"";
    jjrb = "jj rebase";
    jjrbm = "jj rebase -d \"trunk()\"";
    jjrs = "jj restore";
    jjsp = "jj split";
    jjsq = "jj squash";
    jjst = "jj status";
    jjwa = "jj workspace add";
    jjwf = "jj workspace forget";
  };

  # After nushell.nix's NU_LIB_DIRS, which points `use` at nu_scripts.
  programs.nushell.extraConfig = lib.mkAfter ''
    use aliases/git/git-aliases.nu *
  '';
}
