{
  flake.modules.homeManager.noctalia = {
    config,
    lib,
    pkgs,
    ...
  }:
    lib.mkIf config.programs.ghostty.enable {
      programs.ghostty.settings.config-file = "?${config.xdg.configHome}/ghostty/noctalia-theme";

      # Render Noctalia's shipped Ghostty palette without letting its built-in
      # apply hook modify the Home Manager-owned Ghostty config.
      xdg.configFile."noctalia/ghostty-template.toml".text = ''
        [theme.templates.user.ghostty]
        input_path = "${pkgs.noctalia}/share/noctalia/assets/templates/ghostty/ghostty"
        output_path = "$XDG_CONFIG_HOME/ghostty/noctalia-theme"
        post_hook = "bash ${pkgs.noctalia}/share/noctalia/assets/templates/ghostty/reload.sh"
      '';
    };
}
