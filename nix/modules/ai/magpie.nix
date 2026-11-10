{ config, pkgs, ... }:
let
  magpie = pkgs.magpie-cli;
in
{
  home.packages = [ magpie ];

  systemd.user.services.magpie = {
    Unit.Description = "Magpie gateway";
    Service = {
      ExecStart = "${magpie}/bin/magpie serve";
      WorkingDirectory = config.home.homeDirectory;
      Environment = "PATH=${config.home.profileDirectory}/bin:/run/current-system/sw/bin:/run/wrappers/bin";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
