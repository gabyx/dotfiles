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

local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

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
    hide_tab_bar_if_only_one_tab = false,
    use_fancy_tab_bar = false,

    unix_domains = {
        {
            name = "unix",
        },
    },
    default_gui_startup_args = { "connect", "unix" },

    enable_csi_u_key_encoding = false,
    enable_kitty_keyboard = true,
    debug_key_events = false, -- Start `wezterm start --always-new-process` to see the keys

    disable_default_key_bindings = true,

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
    { key = "=",       mods = "LEADER", action = act.IncreaseFontSize },
    { key = "-",       mods = "LEADER", action = act.DecreaseFontSize },
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
    -- {
    --     mods = "LEADER",
    --     key = "w",
    --     action = act.ShowLauncherArgs({
    --         flags = "FUZZY|WORKSPACES",
    --     }),
    -- },

    {
        key = "w",
        mods = "LEADER",
        action = workspace_switcher.switch_workspace(),
    },
    {
        key = "S",
        mods = "LEADER",
        action = workspace_switcher.switch_to_prev_workspace(),
    },
    {
        key = "w",
        mods = "LEADER",
        action = wezterm.action_callback(function(win, pane)
            resurrect.save_state(resurrect.workspace_state.get_workspace_state())
        end),
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

resurrect.periodic_save({ interval_seconds = 30 })
resurrect.change_state_save_dir(os.getenv("HOME") .. "/.config/wezterm/resurrect/state/")
workspace_switcher.apply_to_config(config)

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
-- status.set_status()

-- local function get_current_working_dir(tab)
--     local current_dir = tab.active_pane and tab.active_pane.current_working_dir or { file_path = "" }
--     local HOME_DIR = string.format("file://%s", os.getenv("HOME"))
--
--     return current_dir == HOME_DIR and "~" or string.gsub(current_dir.file_path, ".*/(.*)", "%1")
-- end

-- wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
--     local has_unseen_output = false
--     if not tab.is_active then
--         for _, pane in ipairs(tab.panes) do
--             if pane.has_unseen_output then
--                 has_unseen_output = true
--                 break
--             end
--         end
--     end
--
--     local cwd = wezterm.format({
--         { Attribute = { Intensity = "Bold" } },
--         { Text = get_current_working_dir(tab) },
--     })
--
--     local title = string.format(" [%s] %s", tab.tab_index + 1, cwd)
--
--     if has_unseen_output then
--         return {
--             { Foreground = { Color = "#8866bb" } },
--             { Text = title },
--         }
--     end
--
--     return {
--         { Text = title },
--     }
-- end)

wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(window, path, label)
    local workspace_state = resurrect.workspace_state
    workspace_state.restore_workspace(resurrect.load_state(label, "workspace"), {
        window = window,
        relative = true,
        restore_text = true,
        on_pane_restore = resurrect.tab_state.default_on_pane_restore,
    })
end)

wezterm.on("smart_workspace_switcher.workspace_switcher.selected", function(window, path, label)
    local workspace_state = resurrect.workspace_state
    resurrect.save_state(workspace_state.get_workspace_state())
end)

local resurrect_event_listeners = {
    "resurrect.error",
    "resurrect.save_state.finished",
    "resurrect.workspace_state.restore_workspace.finished",
}

local is_periodic_save = false
wezterm.on("resurrect.periodic_save", function()
    is_periodic_save = true
end)

for _, event in ipairs(resurrect_event_listeners) do
    wezterm.on(event, function(...)
        if event == "resurrect.save_state.finished" and is_periodic_save then
            is_periodic_save = false
            return
        end
        local args = { ... }
        local msg = event
        for _, v in ipairs(args) do
            msg = msg .. " " .. tostring(v)
        end
        wezterm.gui.gui_windows()[1]:toast_notification("Wezterm - resurrect", msg, nil, 0)
    end)
end

wezterm.on("mux-startup", function()
    local _, _, window = mux.spawn_window()
    local workspace_state = resurrect.workspace_state

    -- workspace_state.restore_workspace(resurrect.load_state("custodian", "workspace"), {
    --     window = window,
    --     relative = true,
    --     restore_text = true,
    --     on_pane_restore = resurrect.tab_state.default_on_pane_restore,
    -- })
end)

-- and finally, return the configuration to wezterm
return config
