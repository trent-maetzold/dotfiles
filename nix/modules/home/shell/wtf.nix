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
        columns = [60 60];
        rows = [12 12 12];
      };
      refreshInterval = 1;
      mods = {
        todo = {
          type = "todo";
          title = "Todo";
          filename = "todo.yml"; # in ~/.config/wtf; edit in the widget (n new, space toggle)
          position = {
            top = 0;
            left = 0;
            height = 1;
            width = 1;
          };
          refreshInterval = 3600;
        };
        resources = {
          type = "resourceusage";
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
