# herdr-core (`hc`): terminals for coding agents that outlive the client. The
# daemon runs as a user service; `hc` finds it and doesn't start its own.
{
  config,
  pkgs,
  llm-agents,
  ...
}: let
  herdr-core = llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr-core;
in {
  home.packages = [herdr-core];

  xdg.configFile."herdr-core/config.toml".source = (pkgs.formats.toml {}).generate "herdr-core.toml" {
    shell = ["nu"];
  };

  systemd.user.services.herdr-core = {
    Unit.Description = "herdr-core daemon";
    Service = {
      Type = "exec";
      ExecStart = "${herdr-core}/bin/herdr-core serve";
      WorkingDirectory = config.home.homeDirectory;
      # Terminals inherit this, so they see the user's tools.
      Environment = "PATH=${config.home.profileDirectory}/bin:/run/current-system/sw/bin:/run/wrappers/bin";
      # As `hc server start` does: stopping the core leaves its terminal holders running.
      KillMode = "process";
      OOMPolicy = "continue";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = ["default.target"];
  };
}
