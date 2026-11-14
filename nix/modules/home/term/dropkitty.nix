{
  config,
  lib,
  pkgs,
  ...
}: let
  source = pkgs.fetchzip {
    url = "https://github.com/noctalia-dev/community-plugins/archive/0d394e250618b8409fee7a79dece9110d85d9062.tar.gz";
    hash = "sha256-r4UXm16gOBxjlUkh9tK9OHxZmXOyEPF8/v9vxjY2cGU=";
  };
  plugin =
    pkgs.runCommand "noctalia-dropkitty-0.1.0" {
      nativeBuildInputs = [pkgs.makeWrapper];
    } ''
      mkdir -p "$out/bin"
      cp -r ${source}/dropkitty "$out/dropkitty"
      chmod -R u+w "$out"
      patchShebangs "$out/dropkitty/bin"
      wrapProgram "$out/dropkitty/bin/dropkitty" --prefix PATH : ${lib.makeBinPath [pkgs.kitty pkgs.jq pkgs.util-linux pkgs.coreutils pkgs.gnused pkgs.gnugrep pkgs.niri pkgs.noctalia]}
      ln -s "$out/dropkitty/bin/dropkitty" "$out/bin/dropkitty"
    '';
in {
  home.packages = [plugin];
  xdg.configFile."noctalia/dropkitty.toml".text = ''
    [plugins]
    enabled = ["lowcache/dropkitty"]

    [[plugins.source]]
    name = "dropkitty-nix"
    kind = "path"
    location = "${plugin}"
    enabled = true

    [plugin_settings."lowcache/dropkitty"]
    kitty_conf = "${config.xdg.configHome}/dropkitty/quick-access-terminal.conf"

    [widget.dropkitty]
    type = "lowcache/dropkitty:toggle"

    [bar.default]
    start = ["launcher", "wallpaper", "workspaces", "dropkitty"]
  '';
  xdg.configFile."dropkitty/quick-access-terminal.conf".text = ''
    kitty_override shell=${config.programs.pi-coding-agent.package}/bin/pi
    kitty_override font_family=JetBrainsMono Nerd Font
    kitty_override font_size=12
  '';
}
