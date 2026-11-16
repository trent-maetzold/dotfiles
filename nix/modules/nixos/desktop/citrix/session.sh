# Citrix's X session (run by xinit as `user`): a kiosk window manager and
# Workspace with the employer store, restarted if it exits.
set -u

# Look like the Niri session's GTK apps: dark Adwaita, its icons and cursor.
export XDG_DATA_DIRS="@adwaita@/share:${XDG_DATA_DIRS:-/run/current-system/sw/share}"
export XCURSOR_PATH="@adwaita@/share/icons"
export XCURSOR_THEME=Adwaita XCURSOR_SIZE=24 GTK_THEME=Adwaita:dark
# The user's bus, for audio and the keyring.
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

xset s off -dpms
matchbox-window-manager -use_titlebar no &

if ! storebrowse --liststores | grep -qF "@storeHost@"; then
  storebrowse --addstore "@storeUrl@" || true
fi

while true; do
  selfservice
  sleep 1
done
