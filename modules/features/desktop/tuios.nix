{flake.modules.homeManager.desktop-tuios = {pkgs, ...}: {
  # Keep tuios's writable config.toml for its settings UI; it takes precedence.
  xdg.configFile."tuios/config.d/10-noctalia.toml".text = ''
    [appearance]
    theme = "noctalia"
  '';

  xdg.configFile."noctalia/tuios-theme.json".text = ''
    {
      "id": "noctalia",
      "display_name": "Noctalia",
      "fg": "{{colors.terminal_foreground.default.hex}}",
      "bg": "{{colors.terminal_background.default.hex}}",
      "cursor": "{{colors.terminal_cursor.default.hex}}",
      "black": "{{colors.terminal_normal_black.default.hex}}",
      "red": "{{colors.terminal_normal_red.default.hex}}",
      "green": "{{colors.terminal_normal_green.default.hex}}",
      "yellow": "{{colors.terminal_normal_yellow.default.hex}}",
      "blue": "{{colors.terminal_normal_blue.default.hex}}",
      "purple": "{{colors.terminal_normal_magenta.default.hex}}",
      "cyan": "{{colors.terminal_normal_cyan.default.hex}}",
      "white": "{{colors.terminal_normal_white.default.hex}}",
      "bright_black": "{{colors.terminal_bright_black.default.hex}}",
      "bright_red": "{{colors.terminal_bright_red.default.hex}}",
      "bright_green": "{{colors.terminal_bright_green.default.hex}}",
      "bright_yellow": "{{colors.terminal_bright_yellow.default.hex}}",
      "bright_blue": "{{colors.terminal_bright_blue.default.hex}}",
      "bright_purple": "{{colors.terminal_bright_magenta.default.hex}}",
      "bright_cyan": "{{colors.terminal_bright_cyan.default.hex}}",
      "bright_white": "{{colors.terminal_bright_white.default.hex}}",
      "chrome": {
        "accent": "{{colors.primary.default.hex}}",
        "accent_bright": "{{colors.tertiary.default.hex}}",
        "surface": "{{colors.surface_container.default.hex}}"
      }
    }
  '';

  xdg.configFile."noctalia/tuios-template.toml".text = ''
    [theme.templates.user.tuios]
    input_path = "$XDG_CONFIG_HOME/noctalia/tuios-theme.json"
    output_path = "$XDG_CONFIG_HOME/tuios/themes/noctalia.json"
    post_hook = "${pkgs.tuios}/bin/tuios theme reload"
  '';
};}
