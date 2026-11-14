"""Isolated real-browser smoke test: CAGE LUAKIT USERCONF THEME SCRIPT PALETTE."""
import http.server
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import threading
from pathlib import Path

cage, luakit, userconf, theme, script, palette = sys.argv[1:]
requests = []


class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        requests.append(self.path)
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'<html><body style="background:white;color:black">Test'
                         b'<img src="/blocked.gif"></body></html>')

    def log_message(self, format, *args):
        pass


with http.server.ThreadingHTTPServer(("127.0.0.1", 0), Handler) as server:
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    try:
        for themed in [False, True]:
            with tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                config, data = root / "config/luakit", root / "data/luakit"
                for path in [config, data / "scripts", data / "adblock", root / "runtime"]:
                    path.mkdir(parents=True, mode=0o700)
                shutil.copy(userconf, config / "userconf.lua")
                shutil.copy(theme, config / "theme.lua")
                shutil.copy(script, data / "scripts/darkreader.user.js")
                (data / "adblock/test.txt").write_text("[Adblock Plus 2.0]\n/blocked.gif\n")
                if themed:
                    (config / "noctalia.lua").write_text(re.sub(
                        r"\{\{[^}]+\}\}", "#123456", Path(palette).read_text()))
                marker = root / "passed"
                rc = root / "rc.lua"
                default_rc = Path(luakit).resolve().parent.parent / "etc/xdg/luakit/rc.lua"
                rc.write_text(f'''
                    dofile({json.dumps(str(default_rc))})
                    local settings = require "settings"
                    local theme = require("lousy.theme").get()
                    assert(settings.application.prefer_dark_mode == true)
                    assert(settings.webview.default_font_size == 16)
                    assert(settings.webview.media_playback_requires_gesture == true)
                    assert(theme.bg == "{'#123456' if themed else '#1a1b26'}", tostring(theme.bg))
                    local _, w = next(require("window").bywidget)
                    assert(w and w.win.decorated == false)
                    local seen_http = false
                    w.view:add_signal("load-status", function(v, status)
                        if status ~= "finished" then return end
                        v:eval_js("String(!!window.DarkReader && DarkReader.isEnabled())", {{callback = function(ret, err)
                            assert(not err and ret == "true", tostring(err) .. ":" .. tostring(ret))
                            if v.uri ~= "about:blank" then
                                seen_http = true
                                v.uri = "about:blank"
                            else
                                assert(seen_http)
                                local f = assert(io.open({json.dumps(str(marker))}, "w"))
                                f:write("passed")
                                f:close()
                                luakit.quit()
                            end
                        end}})
                    end)
                ''')
                env = dict(os.environ, HOME=directory, XDG_CONFIG_HOME=str(root / "config"),
                           XDG_DATA_HOME=str(root / "data"), XDG_CACHE_HOME=str(root / "cache"),
                           XDG_RUNTIME_DIR=str(root / "runtime"), WLR_BACKENDS="headless",
                           WLR_RENDERER="pixman", WLR_HEADLESS_OUTPUTS="1")
                for key in ["DISPLAY", "WAYLAND_DISPLAY", "NOTIFY_SOCKET"]:
                    env.pop(key, None)
                with tempfile.TemporaryFile(mode="w+t") as log:
                    child = subprocess.Popen([cage, "--", luakit, "--nounique", "--config", str(rc),
                                              f"http://127.0.0.1:{server.server_port}/"],
                                             env=env, stdout=log, stderr=log)
                    try:
                        child.wait(timeout=30)
                    finally:
                        if child.poll() is None:
                            child.kill()
                            child.wait()
                    log.seek(0)
                    output = log.read()
                    assert child.returncode == 0 and marker.exists(), output
                    assert "/blocked.gif" not in requests, requests
    finally:
        server.shutdown()
        thread.join()
print("Luakit settings, fallback/Noctalia theme, Dark Reader and request blocking passed.")
