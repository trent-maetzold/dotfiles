{
  flake.modules.homeManager.secrets-rbw =
    # Bitwarden through rbw. `rbw unlock` starts rbw-agent, which is also the SSH
    # agent: Bitwarden SSH-key items, never written to disk. rbw's own config
    # (email, server) is left writable for `rbw config set`.
    {
      programs.rbw.enable = true;
      programs.ssh.settings."*".IdentityAgent = "\${XDG_RUNTIME_DIR}/rbw/ssh-agent-socket";
    };
}
