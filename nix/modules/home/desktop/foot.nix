# Foot, on hosts running Niri.
{
  lib,
  osConfig ? {},
  ...
}: {
  config = lib.mkIf (osConfig.programs.niri.enable or false) {
    programs.foot = {
      enable = true;
      settings = {
        main = {
          font = "JetBrainsMono Nerd Font:size=12";
          pad = "14x14";
        };
        csd.preferred = "none";
        scrollback.lines = 10000;
        cursor = {
          style = "block";
          blink = "no";
        };
        key-bindings = {
          clipboard-copy = "Control+Shift+c Control+Insert";
          clipboard-paste = "Control+Shift+v Shift+Insert";
        };
        # Distinct Shift+Enter / Alt+Shift+Enter, for newlines in agent TUIs.
        text-bindings = {
          "\\x1b[13;2u" = "Shift+Return";
          "\\x1b[13;4u" = "Mod1+Shift+Return";
        };
      };
    };
  };
}
