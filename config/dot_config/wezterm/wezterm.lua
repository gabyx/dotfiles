-- Pull in the wezterm API
local wezterm = require("wezterm")
local environment = require("environment")
local astrodark = require("colors/astrodark")
local ssplit = require("smart-splits")

local act = wezterm.action
local mux = wezterm.mux

-- This table will hold the configuration.
local config = wezterm.config_builder()

wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = mux.spawn_window(cmd or {})
    window:gui_window():maximize()

    -- Create a split occupying the right 1/3 of the screen
    pane:split({ size = 0.3 })
    -- Create another split in the right of the remaining 2/3
    -- of the space; the resultant split is in the middle
    -- 1/3 of the display and has the focus.
    pane:split({ size = 0.5 })
end)

local terminfo_dir = os.getenv("TERMINFO_DIRS")
config.set_environment_variables = {
    TERMINFO_DIRS = os.getenv("HOME") .. "/.terminfo" .. (terminfo_dir ~= nil and (":" .. terminfo_dir) or ""),
    WSLENV = "TERMINFO_DIRS",
}
-- Setting it to `wezterm` disable cursor small/bold in the vim plugin.
config.term = "xterm-256color"

-- This is where you actually apply your config choices
config.font_size = 12
config.warn_about_missing_glyphs = false
config.colors = astrodark.colors()
config.window_frame = astrodark.window_frame()
config.hide_tab_bar_if_only_one_tab = true
config.enable_csi_u_key_encoding = false
config.enable_kitty_keyboard = true
config.debug_key_events = false -- Start `wezterm start --always-new-process` to see the keys
config.disable_default_key_bindings = true

if environment.os == "linux" then
    config.window_decorations = "TITLE"
else
    config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
end

config.font = wezterm.font_with_fallback({
    { family = "JetBrainsMono Nerd Font", weight = "Medium" },
    { family = "Noto Color Emoji",        weight = "Medium" },
})

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

config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
    { key = "c", mods = "SHIFT|CTRL", action = act.CopyTo("Clipboard") },

    -- Paste.
    { key = "v", mods = "SHIFT|CTRL", action = act.PasteFrom("Clipboard") },

    -- Activate copy mode or vim mode.
    {
        key = "Enter",
        mods = "LEADER",
        action = wezterm.action.ActivateCopyMode,
    },

    -- Leader stuff
    { key = "p", mods = "LEADER", action = act.ActivateCommandPalette },
    { key = "n", mods = "LEADER", action = act.SpawnWindow },

    -- Font Size
    { key = "=", mods = "LEADER", action = act.IncreaseFontSize },
    { key = "-", mods = "LEADER", action = act.DecreaseFontSize },
    -- Split vertical.
    {
        mods = "LEADER",
        key = "|",
        action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
    },

    -- Split horizontal.
    {
        mods = "LEADER",
        key = "-",
        action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
    },

    -- Close current pane.
    {
        mods = "LEADER",
        key = "x",
        action = wezterm.action({ CloseCurrentPane = { confirm = true } }),
    },

    -- Show the pane selection mode, but have it swap the active and selected panes.
    {
        mods = "LEADER",
        key = "0",
        action = wezterm.action.PaneSelect({
            mode = "SwapWithActive",
        }),
    },

    -- Move between split panes.
    ssplit.split_nav("move", "h"),
    ssplit.split_nav("move", "j"),
    ssplit.split_nav("move", "k"),
    ssplit.split_nav("move", "l"),

    -- Resize panes.
    ssplit.split_nav("resize", "h"),
    ssplit.split_nav("resize", "j"),
    ssplit.split_nav("resize", "k"),
    ssplit.split_nav("resize", "l"),

    -- Show the launcher in fuzzy selection mode and have it list all workspaces
    -- and allow activating one.
    {
        mods = "LEADER",
        key = "w",
        action = act.ShowLauncherArgs({
            flags = "FUZZY|WORKSPACES",
        }),
    },
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
