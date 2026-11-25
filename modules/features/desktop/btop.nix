{
  flake.modules.homeManager.desktop-btop =
    # Render Noctalia's btop palette without writing into the Nix-managed config.
    {pkgs, ...}: {
      programs.btop.settings.color_theme = "noctalia";

      xdg.configFile."noctalia/btop-template.toml".text = ''
        [theme.templates.user.btop]
        input_path = "${pkgs.noctalia}/share/noctalia/assets/templates/btop/btop.theme"
        output_path = "$XDG_CONFIG_HOME/btop/themes/noctalia.theme"
        post_hook = "${pkgs.procps}/bin/pkill -USR2 -u $(${pkgs.coreutils}/bin/id -u) -x btop || true"
      '';
    };
}
