"""Check evaluated dropdown configuration without opening Kitty or starting pi."""
import json
import os
import subprocess
import sys
import tempfile
import tomllib
from pathlib import Path

config = json.loads(Path(sys.argv[1]).read_text())
settings = tomllib.loads(config["noctalia"])
assert settings["plugins"]["enabled"] == ["lowcache/dropkitty"]
source, = settings["plugins"]["source"]
assert source["kind"] == "path" and source["enabled"]
root = Path(source["location"])
manifest = tomllib.loads((root / "dropkitty/plugin.toml").read_text())
assert manifest["id"] == "lowcache/dropkitty" and manifest["plugin_api"] == 26
assert settings["widget"]["dropkitty"]["type"] == "lowcache/dropkitty:toggle"
assert settings["bar"]["default"]["start"] == ["launcher", "wallpaper", "workspaces", "dropkitty"]
assert 'Mod+grave repeat=false { spawn "dropkitty" "toggle"; }' in config["niri"]
assert f'kitty_override shell={config["pi"]}' in config["terminal"].splitlines()
assert Path(config["pi"]).is_file()
helper = root / "bin/dropkitty"
assert helper.resolve().parent == root / "dropkitty/bin"
conf = settings["plugin_settings"]["lowcache/dropkitty"]["kitty_conf"]
assert conf.endswith("/dropkitty/quick-access-terminal.conf")
with tempfile.TemporaryDirectory(prefix="dropkitty-check-") as tmp:
    env = {**os.environ, "XDG_RUNTIME_DIR": tmp}
    subprocess.run([helper, "_settings", f"kitty_conf={conf}"], env=env, check=True, timeout=10)
    assert f"kitty_conf={conf}" in (Path(tmp) / "dropkitty/settings").read_text().splitlines()
    result = subprocess.run([helper, "status"], env=env, check=True, text=True,
                            capture_output=True, timeout=10)
    assert result.stdout.strip() == "alive=0 visible=0"
print("Dropkitty source, bar/key toggle, pi command and isolated helper passed.")
