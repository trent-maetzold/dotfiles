local settings = require "settings"
local window = require "window"

settings.window.home_page = "about:blank"
settings.window.new_tab_page = "about:blank"
settings.webview.default_font_family = "Noto Sans"
settings.webview.sans_serif_font_family = "Noto Sans"
settings.webview.serif_font_family = "Noto Serif"
settings.webview.monospace_font_family = "JetBrainsMono Nerd Font"
settings.webview.default_font_size = 16
settings.webview.default_monospace_font_size = 14
settings.webview.media_playback_requires_gesture = true

window.add_signal("build", function(w)
    w.win.decorated = false
end)
