-- Pull in the wezterm API
local wezterm = require("wezterm")
local astrodark = require("colors/astrodark")

local act = wezterm.action
local mux = wezterm.mux

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end

wezterm.on("gui-startup", function()
    local _, _, window = mux.spawn_window({})
    window:gui_window():maximize()
end)

config.set_environment_variables = {
    TERMINFO_DIRS = os.getenv("HOME") .. "/.terminfo" .. ":" .. os.getenv("TERMINFO_DIRS"),
    WSLENV = "TERMINFO_DIRS",
}
-- Setting it to `wezterm` disable cursor small/bold in the vim plugin.
config.term = "xterm-256color"

-- This is where you actually apply your config choices
config.colors = astrodark.colors()
config.window_frame = astrodark.window_frame()

config.font_size = 12
config.warn_about_missing_glyphs = true
config.font = wezterm.font_with_fallback({
    { family = "JetBrainsMono Nerd Font", weight = "Medium" },
})
config.font_rules = {
    {
        intensity = "Bold",
        italic = false,
        font = wezterm.font({
            family = "JetBrainsMono Nerd Font",
            weight = "ExtraBold",
        }),
    },
    {
        intensity = "Bold",
        italic = true,
        font = wezterm.font({
            family = "JetBrainsMono Nerd Font",
            italic = true,
            weight = "ExtraBold",
        }),
    },
}
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true

config.enable_kitty_keyboard = true
config.debug_key_events = false -- Start `wezterm start --always-new-process` to see the keys
config.disable_default_key_bindings = true

config.leader = { key = "n", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
    -- Copy
    { key = "c", mods = "SHIFT|CTRL", action = act.CopyTo("Clipboard") },
    -- { key = "c", mods = "SUPER", action = act.CopyTo("Clipboard") },

    -- Paste
    { key = "v", mods = "SHIFT|CTRL", action = act.PasteFrom("Clipboard") },
    -- { key = "v", mods = "SUPER", action = act.PasteFrom("Clipboard") },

    -- Leader stuff
    { key = "p", mods = "LEADER", action = act.ActivateCommandPalette },
    { key = "n", mods = "LEADER", action = act.SpawnWindow },
}

-- and finally, return the configuration to wezterm
return config
