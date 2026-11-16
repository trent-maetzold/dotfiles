# Citrix's X session (run by xinit as trent): Win+\ keymap, a
# 1920x1200 screen scaled to the panel, a kiosk window manager, and Workspace
# with the employer store, restarted if it exits.
set -u

# Look like the Niri session's GTK apps: dark Adwaita, its icons and cursor.
export XDG_DATA_DIRS="@adwaita@/share:${XDG_DATA_DIRS:-/run/current-system/sw/share}"
export XCURSOR_PATH="@adwaita@/share/icons"
export XCURSOR_THEME=Adwaita XCURSOR_SIZE=24 GTK_THEME=Adwaita:dark
# trent's user bus, for audio and the keyring.
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

xkbcomp -w 0 -I"@xkbdir@" "@keymap@" "$DISPLAY"
# For the journal: what the server now has on backslash (expect XF86Switch_VT_1).
xmodmap -pke | grep -E "^keycode +51 " || true
xset s off -dpms

output=$(xrandr --query | awk '/ connected/ {print $1; exit}')
# The panel scaler (eDP "scaling mode") upscales a 1920x1200 mode for free.
xrandr --output "$output" --set "scaling mode" "Full aspect" 2>/dev/null || true
if ! xrandr --output "$output" --mode 1920x1200 2>/dev/null; then
  modeline=$(cvt 1920 1200 60 | sed -n 's/^Modeline //p')
  mode=$(echo "$modeline" | awk '{print $1}' | tr -d '"')
  # shellcheck disable=SC2086 # the modeline is several arguments
  xrandr --newmode $modeline
  xrandr --addmode "$output" "$mode"
  xrandr --output "$output" --mode "$mode" ||
    xrandr --output "$output" --scale-from 1920x1200
fi

matchbox-window-manager -use_titlebar no &

if ! storebrowse --liststores | grep -qF "@storeHost@"; then
  storebrowse --addstore "@storeUrl@" || true
fi

while true; do
  selfservice
  sleep 1
done
