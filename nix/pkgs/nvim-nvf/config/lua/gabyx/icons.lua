---@class gabyx.icons
local M = {
    icons,
}

--- Get an icon from the internal icons if it is available and return it
---@param kind string The kind of icon in astroui.icons to retrieve
---@param padding? integer Padding to add to the end of the icon
---@return string icon
M.get_icon = function(kind, padding)
    local icon = M.icons[kind]
    return icon and icon .. (" "):rep(padding or 0) or "⛑️"
end

M.setup = function(opts)
    M.icons = opts.icons

    return M
end

return M
