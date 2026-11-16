# Bitwarden through rbw. `rbw unlock` starts rbw-agent, which is also the SSH
# agent: Bitwarden SSH-key items, never written to disk. rbw's own config
# (email, server, pinentry) is left writable for `rbw config set`.
{pkgs, ...}: {
  programs.rbw.enable = true;
  # rbw-agent asks for the master password through `pinentry` (desktops add a
  # graphical one in desktop/pinentry.nix).
  home.packages = [pkgs.pinentry-curses];

  programs.ssh.settings."*".IdentityAgent = "\${XDG_RUNTIME_DIR}/rbw/ssh-agent-socket";
}
