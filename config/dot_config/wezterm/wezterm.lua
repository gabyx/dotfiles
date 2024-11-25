-- Pull in the wezterm API
local wezterm = require("wezterm")
local environment = require("environment")
local astrodark = require("colors/astrodark")

local act = wezterm.action
local mux = wezterm.mux

-- This table will hold the configuration.
local config = wezterm.config_builder()

local terminfo_dir = os.getenv("TERMINFO_DIRS")
config.set_environment_variables = {
    TERMINFO_DIRS = os.getenv("HOME") .. "/.terminfo" .. (terminfo_dir ~= nil and (":" .. terminfo_dir) or ""),
    WSLENV = "TERMINFO_DIRS",
}

-- This is where you actually apply your config choices
config = {
    font_size = 12,
    font = wezterm.font_with_fallback({
        { family = "JetBrainsMono Nerd Font", weight = "Medium" },
        { family = "Noto Color Emoji",        weight = "Medium" },
    }),

    term = "xterm-256color",
    warn_about_missing_glyphs = false,
    colors = astrodark.colors(),
    window_frame = astrodark.window_frame(),
    hide_tab_bar_if_only_one_tab = true,
    use_fancy_tab_bar = false,

    unix_domains = {
        {
            name = "unix",
        },
    },
    -- default_gui_startup_args = { "connect", "unix" },

    disable_default_key_bindings = true,
    enable_csi_u_key_encoding = false,
    enable_kitty_keyboard = true,
    debug_key_events = false, -- Start `wezterm start --always-new-process` to see the keys

    skip_close_confirmation_for_processes_named = {
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
    },
}

if environment.os == "linux" then
    config.window_decorations = "NONE"
else
    config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
end

config.leader = { key = "g", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
    { key = "c", mods = "SHIFT|CTRL", action = act.CopyTo("Clipboard") },

    -- Paste.
    { key = "v", mods = "SHIFT|CTRL", action = act.PasteFrom("Clipboard") },

    -- Activate copy mode or vim mode.
    {
        mods = "LEADER",
        key = "Enter",
        action = wezterm.action.ActivateCopyMode,
    },

    -- Leader stuff
    { mods = "LEADER", key = "p",       action = act.ActivateCommandPalette },

    -- Font Size
    { key = "j",       mods = "LEADER", action = act.IncreaseFontSize },
    { key = "k",       mods = "LEADER", action = act.DecreaseFontSize },
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

wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = mux.spawn_window(cmd or {})
    window:gui_window():maximize()

    -- Create a split occupying the right 1/3 of the screen
    -- local right = pane:split({ size = 0.5, direction = "Right" })
    -- Create another split in the right of the remaining 2/3
    -- of the space; the resultant split is in the middle
    -- 1/3 of the display and has the focus.
    -- right:split({ size = 0.5, direction = "Bottom" })
end)

-- and finally, return the configuration to wezterm
return config
