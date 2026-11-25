{
  flake.modules.homeManager.shell-ssh =
    # SSH client with strict defaults.
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings."*" = {
          AddKeysToAgent = "no";
          Compression = false;
          ForwardAgent = false;
          HashKnownHosts = false;
          ServerAliveCountMax = 3;
          ServerAliveInterval = 0;
          SetEnv.TERM = "xterm-256color";
          UserKnownHostsFile = "~/.ssh/known_hosts";
        };
      };
    };
}
