"""Check evaluated Niri KDL and Noctalia commands: NIRI_KDL."""
import re
import subprocess
import sys
from pathlib import Path

kdl = Path(sys.argv[1]).read_text()
subprocess.run(["niri", "validate", "--config", sys.argv[1]], check=True)
help_text = subprocess.check_output(["noctalia", "msg", "--help"], text=True)
commands = set(re.findall(r"^  ([a-z][a-z-]+)\b", help_text, re.M))
for command in re.findall(r'spawn "noctalia" "msg" "([^"]+)"', kdl):
    assert command in commands, command
for modifiers, action in {
    "Mod+Alt": "focus-monitor",
    "Mod+Alt+Shift": "move-window-to-monitor",
    "Mod+Ctrl+Alt": "move-column-to-monitor",
    "Mod+Ctrl+Alt+Shift": "move-workspace-to-monitor",
}.items():
    for key, direction in zip("HJKL", ("left", "down", "up", "right"), strict=True):
        assert f"{modifiers}+{key} {{ {action}-{direction}; }}" in kdl
for binding in ("Mod+J { focus-workspace-down; }",
                "Mod+K allow-inhibiting=false { show-hotkey-overlay; }",
                "Mod+Page_Up { focus-workspace-up; }",
                "Mod+grave repeat=false",
                'Mod+Ctrl+Escape allow-inhibiting=false { spawn "noctalia" "msg" "session" "lock"; }'):
    assert binding in kdl, binding
assert "Mod+K { focus-workspace-up; }" not in kdl
print("Niri/Noctalia commands and Win+K shortcut help passed.")
