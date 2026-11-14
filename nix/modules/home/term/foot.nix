# Omarchy's bindings/padding, with Ghostty's default font size.
{
  config,
  lib,
  pkgs,
  ...
}: {
  xdg.configFile."noctalia/templates.toml".text = ''
    [theme.templates]
    enable_builtin_templates = true
    builtin_ids = ["foot"]
  '';

  # Noctalia owns this writable include; Foot requires it to exist at startup.
  home.activation.seedNoctaliaFootTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run ${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArg "${config.xdg.configHome}/foot/themes"}
    if [ ! -e ${lib.escapeShellArg "${config.xdg.configHome}/foot/themes/noctalia"} ]; then
      run ${pkgs.coreutils}/bin/touch ${lib.escapeShellArg "${config.xdg.configHome}/foot/themes/noctalia"}
    fi
  '';

  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "xterm-256color";
        include = "${config.xdg.configHome}/foot/themes/noctalia";
        font = "JetBrainsMono Nerd Font:size=12";
        pad = "14x14";
        initial-window-mode = "windowed";
        workers = 0;
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
        primary-paste = "none";
      };
      text-bindings = {
        "\\x1b[13;2u" = "Shift+Return";
        "\\x1b[13;4u" = "Mod1+Shift+Return";
      };
    };
  };
}
