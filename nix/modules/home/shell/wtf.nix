# wtf (wtfutil) terminal dashboard. Hosts add widgets under programs.wtf.settings.wtf.mods.
{
  config,
  lib,
  pkgs,
  ...
}: let
  yaml = pkgs.formats.yaml {};
in {
  options.programs.wtf.settings = lib.mkOption {
    inherit (yaml) type;
    default = {};
  };

  config = {
    home.packages = [pkgs.wtfutil];
    xdg.configFile."wtf/config.yml".source = yaml.generate "wtf.yml" config.programs.wtf.settings;

    programs.wtf.settings.wtf = {
      grid = {
        columns = [0 0];
        rows = [0 0 0];
      };
      refreshInterval = 1;
      mods = lib.mkDefault {
        todo = {
          type = "cmdrunner";
          enabled = true;
          title = "Todo";
          cmd = "todo";
          args = ["--color" "always" "list"]; # edit with the todo CLI
          position = {
            top = 0;
            left = 0;
            height = 1;
            width = 1;
          };
          refreshInterval = 300;
        };
        resources = {
          type = "resourceusage";
          enabled = true;
          position = {
            top = 0;
            left = 1;
            height = 1;
            width = 1;
          };
          refreshInterval = 1;
        };
      };
    };
  };
}
