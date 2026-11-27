{
  config,
  pkgs,
  ...
}: {
  # CLI for `magpie provider add …` etc. on the host.
  home.packages = [pkgs.magpie-cli];

  systemd.user.services.magpie = {
    Unit.Description = "Magpie model gateway";
    Service = {
      ExecStart = "${pkgs.magpie-cli}/bin/magpie serve";
      WorkingDirectory = config.home.homeDirectory;
      Environment = [
        # Callers arrive from loopback, which magpie trusts without a gateway key.
        "MAGPIE_ADDR=127.0.0.1:3425"
        "PATH=${config.home.profileDirectory}/bin:/run/current-system/sw/bin:/run/wrappers/bin"
      ];
      Restart = "always";
      RestartSec = 5;
    };
    Install.WantedBy = ["default.target"];
  };
}
