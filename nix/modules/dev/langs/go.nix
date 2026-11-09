{ config, pkgs, ... }:
{
  programs.go = {
    enable = true;
    env = {
      GOPATH = "${config.xdg.dataHome}/go";
      GOMODCACHE = "${config.xdg.cacheHome}/go/mod";
    };
    telemetry.mode = "off";
  };

  home.sessionPath = [ "${config.xdg.dataHome}/go/bin" ];
  home.packages = with pkgs; [ gopls delve ];
}
