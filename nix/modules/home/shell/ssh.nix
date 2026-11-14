# Bitwarden-backed SSH agent; hosts come from the system flake.
{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.rbw.enable = true;
  # Leave rbw's account/server configuration writable for first-login setup.
  home.packages = [pkgs.pinentry-qt];

  sshAuthSock = {
    enable = true;
    initialization = {
      bash = ''export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/rbw/ssh-agent-socket"'';
      fish = ''set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/rbw/ssh-agent-socket"'';
      nushell = ''$env.SSH_AUTH_SOCK = $"($env.XDG_RUNTIME_DIR)/rbw/ssh-agent-socket"'';
    };
    systemd.socketProviderUnit = "rbw-agent.service";
  };

  systemd.user.services.rbw-agent = {
    Unit.Description = "Bitwarden vault and SSH agent";
    Service = {
      # Reuse the daemon already started by `rbw unlock` before a switch.
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${config.programs.rbw.package}/bin/rbw-agent";
      Environment = "PATH=${lib.makeBinPath [pkgs.pinentry-qt]}";
    };
    Install.WantedBy = ["default.target"];
  };

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
      UserKnownHostsFile = "~/.ssh/known_hosts";
    };
  };
}
