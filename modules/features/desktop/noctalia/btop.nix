{
  flake.modules.homeManager.noctalia =
    # Render Noctalia's btop palette without writing into the Nix-managed config.
    {
      config,
      lib,
      pkgs,
      ...
    }:
      lib.mkIf config.programs.btop.enable {
        programs.btop.settings.color_theme = "noctalia";

        xdg.configFile."noctalia/btop-template.toml".text = ''
          [theme.templates.user.btop]
          input_path = "${pkgs.noctalia}/share/noctalia/assets/templates/btop/btop.theme"
          output_path = "$XDG_CONFIG_HOME/btop/themes/noctalia.theme"
          post_hook = "${pkgs.procps}/bin/pkill -USR2 -u $(${pkgs.coreutils}/bin/id -u) -x btop || true"
        '';
      };
}
