# Bitwarden through rbw, with rbw-agent as the SSH agent: keys stay in the
# vault and SSH_AUTH_SOCK points at the agent. rbw's own config (email, server,
# pinentry) is left writable for `rbw config set`.
{
  config,
  pkgs,
  ...
}: let
  socket = "rbw/ssh-agent-socket";
in {
  programs.rbw.enable = true;
  # rbw-agent asks for the master password through `pinentry` (desktops add a
  # graphical one in desktop/pinentry.nix).
  home.packages = [pkgs.pinentry-curses];

  systemd.user.services.rbw-agent = {
    Unit = {
      Description = "Bitwarden (rbw) agent and SSH agent";
      # rbw-agent exits until `rbw config set email ...` has written its config.
      ConditionPathExists = "%E/rbw/config.json";
    };
    Service = {
      ExecStart = "${config.programs.rbw.package}/bin/rbw-agent --no-daemonize";
      Environment = "PATH=${config.home.profileDirectory}/bin";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = ["default.target"];
  };

  sshAuthSock = {
    enable = true;
    initialization = {
      bash = ''export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/${socket}"'';
      fish = ''set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/${socket}"'';
      nushell = ''$env.SSH_AUTH_SOCK = $"($env.XDG_RUNTIME_DIR)/${socket}"'';
    };
    systemd.socketProviderUnit = "rbw-agent.service";
  };
}
