# Keyboard map: muninn

`Super` is the Windows/Mod key. **Super+K** (or Super+Shift+/) shows Niri's
shortcut overlay. Super+PageUp still selects the previous workspace; Super+K
no longer does that.

## Niri: windows, columns and workspaces

| Super + keys | Action |
| --- | --- |
| K or Shift+/ | Show desktop shortcut overlay |
| H/L | Focus column left/right |
| J / PageUp | Next/down / previous/up workspace |
| Shift+H/L | Move column left/right |
| Shift+J/K | Send window to next/previous workspace |
| Ctrl+J/K | Focus window down/up within a column |
| Ctrl+Shift+J/K | Move window down/up within a column |
| Ctrl+H/L | Focus first/last column |
| Ctrl+Shift+H/L | Move column to first/last position |
| Tab / Ctrl+Tab | Previously focused window / workspace |
| 1…9 / Shift+1…9 | Focus workspace / send window there |
| PageUp/Down | Previous/next workspace |
| Shift+PageUp/Down | Send window to previous/next workspace |
| Ctrl+PageUp/Down | Reorder workspace up/down |
| Ctrl+Shift+PageUp/Down | Send entire column to previous/next workspace |
| Left/Right, Up/Down | Focus column left/right, window up/down |
| Shift+arrows | Move column/window in that direction |
| [ / ] | Consume or expel a window left/right |
| R / Alt+R | Next/previous preset column width |
| Shift+R / Alt+Shift+R | Next/previous preset window height |
| Ctrl+R | Reset window height |
| Ctrl+Shift+R | Cycle preset window width |
| Ctrl+Alt+R | Expand column into available space |
| minus/equal | Shrink/grow column width |
| Shift+minus/equal | Shrink/grow window height |
| Ctrl+minus/equal | Shrink/grow individual window width |
| C / Shift+C / Ctrl+C | Center column / window / visible columns |
| F / Shift+F | Maximize column / fullscreen window |
| Ctrl+F / Alt+F | Windowed fullscreen / maximize window to edges |
| V / Shift+V | Toggle floating / switch floating-versus-tiled focus |
| Ctrl+V / Ctrl+Shift+V | Focus floating / tiled layout |
| Alt+V / Alt+Shift+V | Move window explicitly to floating / tiling |
| W / O | Toggle tabbed column / overview |
| Alt+O | Toggle window-rule opacity |
| Q | Close window |
| Shift+E | Niri quit confirmation |
| Escape | Toggle client shortcut inhibition |

### Monitors: H/J/K/L means left/down/up/right

| Super + keys | Action |
| --- | --- |
| Alt+H/J/K/L | Focus monitor |
| Alt+Shift+H/J/K/L | Move window to monitor |
| Ctrl+Alt+H/J/K/L | Move column to monitor |
| Ctrl+Alt+Shift+H/J/K/L | Move workspace to monitor |
| Ctrl+Alt+S | Set dynamic screencast target to window |
| Ctrl+Alt+Shift+S | Set dynamic screencast target to monitor |
| Ctrl+Alt+Escape | Clear dynamic screencast target |

## Noctalia and application launchers

| Super + keys | Action |
| --- | --- |
| Space or D | Native Noctalia launcher |
| Return / grave | Foot / dropdown Kitty running pi |
| A / Shift+A | Audio panel / full control center |
| I | Monitor/brightness panel |
| B / Shift+B / Ctrl+B | Toggle bar / Bluetooth / Wi-Fi |
| E | Noctalia settings |
| N / Shift+N | Notifications / Do Not Disturb |
| Alt+N / Ctrl+N | Dismiss active notifications / invoke latest notification action |
| P / Shift+P / Ctrl+P | Clipboard / session menu / emoji picker |
| Ctrl+Escape | Lock, never inhibited |
| Pause / Shift+Pause / Ctrl+Pause | Caffeine / night light / OSD toggle |
| Shift+D | Toggle dock |
| Ctrl+D / Ctrl+Shift+D | Toggle desktop widgets / widget editing |
| Alt+D | Toggle dark/light theme mode |
| Ctrl+Space | Cycle configured keyboard layouts |
| Alt+minus/equal / Alt+M | Speaker volume down/up / mute |
| Alt+Shift+minus/equal / Ctrl+Alt+M | Microphone volume down/up / mute |
| Alt+comma/period | Brightness down/up |
| Alt+P / Alt+[ / Alt+] | Media play/pause / previous / next |
| Alt+Shift+P | Cycle available power profiles |
| Ctrl+Alt+[ / Ctrl+Alt+] | Previous/next wallpaper |

Hardware volume, mute, mic-mute, screen/keyboard brightness and media keys use
Noctalia, including while locked. Wi-Fi/Bluetooth toggles can interrupt calls.
Dropkitty is a separate Kitty layer-shell window, not an embedded Noctalia panel.
Restarting it terminates its terminal session; hiding it does not.

### Screenshots (no Super)

| Keys | Action |
| --- | --- |
| Print | Niri region picker |
| Ctrl+Print / Alt+Print | Screen / window |
| Shift+Print | Noctalia annotation overlay |
