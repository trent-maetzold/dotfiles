local theme = dofile("@luakit@/etc/xdg/luakit/theme.lua")
local colors = {
    bg = "#1a1b26", fg = "#c0caf5", surface = "#24283b",
    primary = "#7aa2f7", on_primary = "#1a1b26",
    secondary = "#9ece6a", error = "#f7768e", outline = "#565f89",
}
local palette = luakit.config_dir .. "/noctalia.lua"
if require("lfs").attributes(palette) then colors = dofile(palette) end

theme.font = '12pt "JetBrainsMono Nerd Font", "Noto Sans"'
theme.hint_font = theme.font
theme.fg, theme.bg = colors.fg, colors.bg
for _, prefix in ipairs({ "sbar", "dbar", "ibar", "menu", "notif" }) do
    theme[prefix .. "_fg"], theme[prefix .. "_bg"] = colors.fg, colors.bg
end
theme.menu_title_bg = colors.surface
theme.menu_primary_title_fg = colors.primary
theme.menu_secondary_title_fg = colors.secondary
theme.menu_selected_fg, theme.menu_selected_bg = colors.on_primary, colors.primary
theme.menu_disabled_fg = colors.outline
theme.menu_enabled_fg, theme.menu_active_fg = colors.fg, colors.secondary
theme.menu_disabled_bg, theme.menu_enabled_bg, theme.menu_active_bg = colors.surface, colors.surface, colors.surface
theme.tab_fg, theme.tab_bg = colors.fg, colors.surface
theme.tab_hover_bg = colors.outline
theme.tab_ntheme, theme.selected_ntheme = colors.secondary, colors.primary
theme.selected_fg, theme.selected_bg = colors.on_primary, colors.primary
theme.loading_fg, theme.loading_bg = colors.primary, colors.bg
theme.success_fg, theme.loaded_fg, theme.trust_fg = colors.secondary, colors.primary, colors.secondary
theme.error_fg, theme.error_bg = colors.bg, colors.error
theme.warning_fg, theme.warning_bg = colors.bg, colors.error
theme.notrust_fg, theme.dbar_error_fg = colors.error, colors.error
theme.hint_fg, theme.hint_bg = colors.on_primary, colors.primary
theme.hint_border = "1px solid " .. colors.outline
theme.ok = { fg = colors.fg, bg = colors.bg }
theme.warn = { fg = colors.bg, bg = colors.error }
theme.error = theme.warn
return theme
