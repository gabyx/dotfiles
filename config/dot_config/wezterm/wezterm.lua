-- Pull in the wezterm API
local wezterm = require("wezterm")
local environment = require("environment")
local astrodark = require("colors/astrodark")
local ssplit = require("smart-splits")
local status = require("status")

local act = wezterm.action
local mux = wezterm.mux

-- This table will hold the configuration.
local config = wezterm.config_builder()

-- TODO: Find a solution to use these, but safe. -> Store in Nix
-- local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
-- local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

local terminfo_dir = os.getenv("TERMINFO_DIRS")
config.set_environment_variables = {
    TERMINFO_DIRS = os.getenv("HOME") .. "/.terminfo" .. (terminfo_dir ~= nil and (":" .. terminfo_dir) or ""),
    WSLENV = "TERMINFO_DIRS",
}

config.default_ssh_auth_sock = os.getenv("SSH_AUTH_SOCK")

-- This is where you actually apply your config choices
config = {
    front_end = "WebGPU",

    font_size = 12,
    warn_about_missing_glyphs = false,
    font = wezterm.font_with_fallback({
        { family = "JetBrainsMono Nerd Font", weight = "Medium" },
        { family = "DejaVu Sans Mono", weight = "Medium" },
        "Noto Color Emoji",
    }),

    term = "xterm-256color",

    colors = astrodark.colors(),
    window_frame = astrodark.window_frame(),
    hide_tab_bar_if_only_one_tab = false,
    tab_bar_at_bottom = true,
    use_fancy_tab_bar = false,

    unix_domains = {
        {
            name = "unix",
        },
    },
    -- default_gui_startup_args = { "connect", "unix" },

    disable_default_key_bindings = true,
    enable_csi_u_key_encoding = false,
    enable_kitty_keyboard = false,
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

    leader = { key = "g", mods = "CTRL", timeout_milliseconds = 1000 },

    tiling_desktop_environments = {
        "Wayland",
    },

    check_for_updates = false,
}

if environment.os == "linux" then
    config.window_decorations = "NONE"
else
    config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
end

-- Set GPU
for _, gpu in ipairs(wezterm.gui.enumerate_gpus()) do
    if gpu.backend == "Vulkan" then
        config.webgpu_preferred_adapter = gpu
        config.front_end = "WebGpu"
        break
    end
end

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
    { mods = "LEADER", key = "p", action = act.ActivateCommandPalette },
    {
        mods = "LEADER|SHIFT",
        key = "c",
        action = act.PromptInputLine({
            description = wezterm.format({
                { Attribute = { Intensity = "Bold" } },
                { Foreground = { AnsiColor = "Fuchsia" } },
                { Text = "Enter name for new workspace" },
            }),
            action = wezterm.action_callback(function(window, pane, line)
                -- line will be `nil` if they hit escape without entering anything
                -- An empty string if they just hit enter
                -- Or the actual line of text they wrote
                if line then
                    window:perform_action(
                        act.SwitchToWorkspace({
                            name = line,
                        }),
                        pane
                    )
                end
            end),
        }),
    },

    -- Font Size
    { key = "mapped:=", mods = "CTRL", action = act.IncreaseFontSize },
    { key = "mapped:-", mods = "CTRL", action = act.DecreaseFontSize },
    -- Split vertical.
    {
        mods = "LEADER",
        key = "mapped:-",
        action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
    },

    -- Split horizontal.
    {
        mods = "LEADER",
        key = "\\",
        action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
    },

    -- Close current pane.
    {
        mods = "LEADER",
        key = "x",
        action = wezterm.action({ CloseCurrentPane = { confirm = true } }),
    },
    -- Create a new tab in the same domain as the current pane.
    -- This is usually what you want.
    {
        mods = "LEADER",
        key = "t",
        action = act.SpawnTab("CurrentPaneDomain"),
    },
    -- Close current tab.
    {
        mods = "LEADER|SHIFT",
        key = "X",
        action = wezterm.action({ CloseCurrentTab = { confirm = true } }),
    },
    -- Create new tab.
    {
        mods = "LEADER",
        key = "c",
        action = act.SpawnTab("CurrentPaneDomain"),
    },

    -- Navigate tabs.
    { key = ";", mods = "CTRL", action = act.ActivateTabRelative(-1) },
    { key = "'", mods = "CTRL", action = act.ActivateTabRelative(1) },

    -- Show the pane selection mode, but have it swap the active and selected panes.
    {
        mods = "LEADER",
        key = "s",
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

-- Set the status on the top.
status.set_status()

-- and finally, return the configuration to wezterm
return config
