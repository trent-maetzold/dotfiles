"""Check evaluated Zen config: CONFIG_JSON."""
import json
import sys
from pathlib import Path

config = json.loads(Path(sys.argv[1]).read_text())
extensions = config["policies"]["ExtensionSettings"]
for addon, slug in {
    "vimium-c@gdh1995.cn": "vimium-c",
    "{446900e4-71c2-419f-a6a7-df9c091e268b}": "bitwarden-password-manager",
}.items():
    assert extensions[addon] == {
        "installation_mode": "force_installed",
        "install_url": f"https://addons.mozilla.org/firefox/downloads/latest/{slug}/latest.xpi",
    }
assert config["profilePath"] == "default"
assert config["forceSelector"] is True
assert config["settings"]["browser.ctrlTab.sortByRecentlyUsed"] is False
assert config["shortcuts"] == [], "Zen should use its stock keyboard bindings"
assert not Path("nix/modules/home/zen-vimium.txt").exists()
print("Zen extension policy, existing profile and stock keyboard bindings passed.")
