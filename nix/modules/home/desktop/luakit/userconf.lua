local settings = require "settings"
local window = require "window"
local modes = require "modes"

settings.application.prefer_dark_mode = true
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

modes.add_binds("normal", {
    { ",p", "Choose a Bitwarden entry to copy (verify the HTTPS origin first).", function()
        luakit.spawn("@rbwMenu@/bin/rbw-menu")
    end },
    { ",d", "Toggle Dark Reader on this page.", function(w)
        w.view:eval_js([[if (window.DarkReader) {
            if (DarkReader.isEnabled()) DarkReader.disable();
            else DarkReader.enable({brightness: 100, contrast: 100, sepia: 0});
        }]], {})
    end },
})
