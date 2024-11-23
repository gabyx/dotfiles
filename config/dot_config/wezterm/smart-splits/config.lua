local w = require("wezterm")
local M = {}

-- if you are *NOT* lazy-loading smart-splits.nvim (recommended)
local function is_vim(pane)
    -- this is set by the plugin, and unset on ExitPre in Neovim
    return pane:get_user_vars().IS_NVIM == "true"
end

local direction_keys = {
    h = "Left",
    j = "Down",
    k = "Up",
    l = "Right",
}

M.split_nav = function(resize_or_move, key, mod)
    return {
        key = key,

        mods = resize_or_move == "resize" and "META" or "CTRL",

        action = w.action_callback(function(win, pane)
            if is_vim(pane) then
                -- Pass the keys through to vim/nvim.
                win:perform_action({
                    SendKey = { key = key, mods = resize_or_move == "resize" and "META" or "CTRL" },
                }, pane)
            else
                if resize_or_move == "resize" then
                    win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
                else
                    win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
                end
            end
        end),
    }
end

return M
