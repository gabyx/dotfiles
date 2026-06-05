local M = {}
M.config = require("gabyxui.config")

--- Get an icon from the AstroNvim internal icons if it is available and return it
---@param kind string The kind of icon in astroui.icons to retrieve
---@param padding? integer Padding to add to the end of the icon
---@return string icon
function M.get_icon(kind, padding)
    local icon = M.config.icons[kind]
    return icon and icon .. (" "):rep(padding or 0) or "⛑️"
end

--- The setup function.
function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts)
    M.toggles = require("gabyxui.toggles")
end

return M
