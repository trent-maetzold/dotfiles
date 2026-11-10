{
  config,
  pkgs,
  ...
}: {
  # Daemon and CLI, not paseo.desktop.
  home.packages = [pkgs.paseo];

  systemd.user.services.paseo = {
    Unit.Description = "Paseo daemon";
    Service = {
      ExecStart = "${pkgs.paseo}/bin/paseo daemon run";
      WorkingDirectory = config.home.homeDirectory;
      Environment = "PATH=${config.home.profileDirectory}/bin:/run/current-system/sw/bin:/run/wrappers/bin";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = ["default.target"];
  };
}
