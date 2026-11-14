{
  lib,
  pkgs,
  ...
}: let
  picker = pkgs.rofi-rbw.override {waylandSupport = true;};
  # Fuzzel's unused default custom keys otherwise index past the picker bindings.
  disabledPickerKeys = lib.concatMapStringsSep " " (n: "--override=key-bindings.custom-${toString n}=none") (lib.range 4 9);
  rbwMenu = pkgs.writeShellApplication {
    name = "rbw-menu";
    runtimeInputs = [pkgs.fuzzel];
    text = ''
      exec ${picker}/bin/rofi-rbw --selector fuzzel --action copy \
        --target password --clear-after 30 --no-cache \
        --keybindings 'Alt+u:copy:username,Alt+p:copy:password,Alt+t:copy:totp' \
        --selector-args=${lib.escapeShellArg disabledPickerKeys}
    '';
  };
  darkreader = pkgs.fetchurl {
    url = "https://registry.npmjs.org/darkreader/-/darkreader-4.9.135.tgz";
    sha256 = "1rf89s7i1961mglb0jakqbi9bwbh1hj73jvrx1y7yzas92xqsi71";
  };
  darkScript = pkgs.runCommand "luakit-darkreader.user.js" {} ''
    cat > "$out" <<'HEADER'
    // ==UserScript==
    // @name Dark Reader
    // @description Locally bundled Dark Reader; no runtime script downloads.
    // @match http://*/*
    // @match https://*/*
    // @include about:blank
    // @run-at document-end
    // ==/UserScript==
    HEADER
    tar -xOf ${darkreader} package/darkreader.js >> "$out"
    echo 'DarkReader.setFetchMethod(window.fetch.bind(window));' >> "$out"
    echo 'DarkReader.enable({brightness: 100, contrast: 100, sepia: 0});' >> "$out"
  '';
  filter = id: hash:
    pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/7bb2f42c8821a09f2c9c022ccb769dc2613ae440/filters/filter_${id}/filter.txt";
      sha256 = hash;
    };
in {
  home.packages = [pkgs.luakit rbwMenu];
  xdg.configFile = {
    "luakit/theme.lua".source = pkgs.replaceVars ./luakit/theme.lua {luakit = pkgs.luakit;};
    "luakit/userconf.lua".source = pkgs.replaceVars ./luakit/userconf.lua {inherit rbwMenu;};
    "noctalia/templates/luakit.lua".text = ''
      return {
        bg = "{{colors.surface.default.hex}}",
        fg = "{{colors.on_surface.default.hex}}",
        surface = "{{colors.surface_container.default.hex}}",
        primary = "{{colors.primary.default.hex}}",
        on_primary = "{{colors.on_primary.default.hex}}",
        secondary = "{{colors.secondary.default.hex}}",
        error = "{{colors.error.default.hex}}",
        outline = "{{colors.outline.default.hex}}",
      }
    '';
    "noctalia/templates.toml".text = lib.mkAfter ''
      [theme.templates.user.luakit]
      input_path = "$XDG_CONFIG_HOME/noctalia/templates/luakit.lua"
      output_path = "$XDG_CONFIG_HOME/luakit/noctalia.lua"
    '';
  };
  xdg.dataFile = {
    "luakit/scripts/darkreader.user.js".source = darkScript;
    # Luakit supports the request rules, not cosmetic/extended filter syntax.
    "luakit/adblock/base.txt".source = filter "2_Base" "0cpsapwx441p1rr75qi29l6i898s8czfi4qr2di6j38n9j1rf6hn";
    "luakit/adblock/privacy.txt".source = filter "3_Spyware" "0mh1gmifvlamhx5r82jih5m25lx8b7rrrpdiy9z8n2pw5ppqhyrs";
    "luakit/adblock/annoyances.txt".source = filter "14_Annoyances" "0xvbwzgp72psxlml1hl60vjhih56gl682lw54d7bqhp3080181ia";
  };
}
