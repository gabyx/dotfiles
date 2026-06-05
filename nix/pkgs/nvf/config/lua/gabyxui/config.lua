---@class Settings
--- List of icons map.
--- @field icons table<string,string>

---@type Settings
local M = {
    --- Will be set from Nix.
    icons = {},

    features = {
        autopairs = true,

        -- Global completion.
        cmp = true,
        -- Buffer completion.
        completion = true,

        -- URL highlight.
        highlighturl = true,
    },
}

return M
