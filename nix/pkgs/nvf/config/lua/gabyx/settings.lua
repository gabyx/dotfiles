local M = {}

---@class LargeBugCfg
---@field enabled (boolean|fun(bufnr: integer, config: LargeBugCfg):boolean|LargeBugCfg?)? whether to enable large file detection
---@field notify boolean? whether or not to display a notification when a large file is detected
---@field size integer|false? the number of bytes in a file or false to disable check
---@field lines integer|false? the number of lines in a file or false to disable check
---@field line_length integer|false? the average line length in a file or false to disable check buffer settings.

---@type LargeBugCfg
M.large_buf_opts = {
    enabled = true,
    size = 1000 * 1024 * 1024,
    lines = 100000,
    line_length = nil,
}

return M
