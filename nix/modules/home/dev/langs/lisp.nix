# Common Lisp: SBCL, as used by autolith. rlwrap gives the bare REPL line editing.
{pkgs, ...}: {
  home.packages = with pkgs; [sbcl rlwrap];
}
