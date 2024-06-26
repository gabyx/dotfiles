-- Pull in the wezterm API
local wezterm = require("wezterm")
local environment = require("environment")
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

wezterm.on("gui-startup", function(cmd)
    local _, _, window = mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

terminfo_dir = os.getenv("TERMINFO_DIRS")
config.set_environment_variables = {
    TERMINFO_DIRS = os.getenv("HOME") .. "/.terminfo" .. (terminfo_dir ~= nil and (":" .. terminfo_dir) or ""),
    WSLENV = "TERMINFO_DIRS",
}
-- Setting it to `wezterm` disable cursor small/bold in the vim plugin.
config.term = "xterm-256color"

-- This is where you actually apply your config choices
config.colors = astrodark.colors()
config.window_frame = astrodark.window_frame()

config.font_size = 12
config.warn_about_missing_glyphs = false
config.font = wezterm.font_with_fallback({
    { family = "JetBrainsMono Nerd Font", weight = "Medium" },
    { family = "Noto Color Emoji",        weight = "Medium" },
})

-- config.font_rules = {
--     {
--         intensity = "Normal",
--         italic = true,
--         font = wezterm.font({
--             family = "JetBrainsMono Nerd Font",
--             italic = true,
--             weight = "Medium",
--         }),
--     },
--     {
--         intensity = "Bold",
--         italic = false,
--         font = wezterm.font({
--             family = "JetBrainsMono Nerd Font",
--             weight = "ExtraBold",
--         }),
--     },
--     {
--         intensity = "Bold",
--         italic = true,
--         font = wezterm.font({
--             family = "JetBrainsMono Nerd Font",
--             italic = true,
--             weight = "ExtraBold",
--         }),
--     },
-- }

config.skip_close_confirmation_for_processes_named = {
    "bash",
    "sh",
    "zsh",
    "fish",
    "tmux",
    "cmd.exe",
    "pwsh.exe",
    "powershell.exe",
    "lf",
    "btop",
    "journalctl",
}

if environment.os == "linux" then
    config.window_decorations = "NONE"
else
    config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
end

config.hide_tab_bar_if_only_one_tab = true
config.enable_csi_u_key_encoding = false
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
    { key = "p", mods = "LEADER",     action = act.ActivateCommandPalette },
    { key = "n", mods = "LEADER",     action = act.SpawnWindow },

    -- Font Size
    { key = "=", mods = "LEADER",     action = act.IncreaseFontSize },
    { key = "-", mods = "LEADER",     action = act.DecreaseFontSize },
}

config.mouse_bindings = {
    -- Scrolling up while holding CTRL increases the font size
    -- Inside `tmux` press `Shift+Ctrl+Scroll` to bypass
    -- mouse event tracking.
    {
        event = { Down = { streak = 1, button = { WheelUp = 1 } } },
        mods = "CTRL",
        action = act.IncreaseFontSize,
    },
    -- Scrolling down while holding CTRL decreases the font size
    {
        event = { Down = { streak = 1, button = { WheelDown = 1 } } },
        mods = "CTRL",
        action = act.DecreaseFontSize,
    },
}

-- and finally, return the configuration to wezterm
return config
