{config, pkgs, ...}: {
  # Ghostty is the default terminal; Noctalia's terminal actions read TERMINAL.
  home.sessionVariables.TERMINAL = "ghostty";
  systemd.user.sessionVariables.TERMINAL = "ghostty";

  # Render Noctalia's shipped Ghostty palette without letting its built-in
  # apply hook modify the Home Manager-owned Ghostty config.
  xdg.configFile."noctalia/ghostty-template.toml".text = ''
    [theme.templates.user.ghostty]
    input_path = "${pkgs.noctalia}/share/noctalia/assets/templates/ghostty/ghostty"
    output_path = "$XDG_CONFIG_HOME/ghostty/noctalia-theme"
    post_hook = "bash ${pkgs.noctalia}/share/noctalia/assets/templates/ghostty/reload.sh"
  '';

  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 12;
      config-file = "?${config.xdg.configHome}/ghostty/noctalia-theme";
      # Split leftover pixels from the terminal's whole-cell grid across both edges.
      window-padding-balance = "equal";
    };
  };
}
