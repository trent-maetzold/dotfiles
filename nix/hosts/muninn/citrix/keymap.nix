# US keymaps where Win+\ switches VT: Niri's (niri.xkb) to Citrix's VT, and
# Xorg's (xorg.xkb) back to Niri's. Only backslash changes: a Super level
# emitting XF86Switch_VT_<n>. Niri switches on that keysym itself; Xorg's
# compat rules map it to SwitchScreen, handled by the server even while
# Citrix grabs the keyboard.
{
  libxkbcommon,
  python3,
  runCommand,
  xkeyboard_config,
  citrixVt,
  niriVt,
}: let
  superLevel3 = ''
    type "SUPER_LEVEL3" {
      modifiers= Shift+Mod4;
      map[Shift]= Level2;
      map[Mod4]= Level3;
      map[Shift+Mod4]= Level3;
      level_name[Level1]= "Base";
      level_name[Level2]= "Shift";
      level_name[Level3]= "Super";
    };
  '';
  backslash = vt: ''override key <BKSL> { type= "SUPER_LEVEL3", symbols[Group1]= [ backslash, bar, XF86Switch_VT_${toString vt} ] };'';
in
  runCommand "vt-switch-keymaps" {
    nativeBuildInputs = [libxkbcommon python3];
    passAsFile = ["xorg"];
    # For xkbcomp -I<xkeyboard-config> against the X server.
    xorg = ''
      xkb_keymap {
        xkb_keycodes { include "evdev+aliases(qwerty)" };
        xkb_types { include "complete"
          ${superLevel3}
        };
        xkb_compat { include "complete" };
        xkb_symbols { include "pc+us+inet(evdev)"
          ${backslash niriVt}
        };
        xkb_geometry { include "pc(pc105)" };
      };
    '';
  } ''
    mkdir -p "$out"
    cp "$xorgPath" "$out/xorg.xkb"
    # Niri reads a complete keymap: compile US, then add the Super level.
    XKB_CONFIG_ROOT=${xkeyboard_config}/share/X11/xkb xkbcli compile-keymap --layout us > us.xkb
    python3 - "$out/niri.xkb" <<'PY'
    import sys
    s = open("us.xkb").read()
    s = s.replace('\ttype "TWO_LEVEL" {', ${builtins.toJSON superLevel3} + '\ttype "TWO_LEVEL" {', 1)
    old = "\tkey <BKSL>               {\t[       backslash,             bar ] };"
    assert old in s, "unexpected <BKSL> definition"
    open(sys.argv[1], "w").write(s.replace(old, ${builtins.toJSON (backslash citrixVt)}))
    PY
  ''
