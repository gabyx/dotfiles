---@class gabyx.diagnostic
local M = {}

function M.jump(dir, severity)
    local jump_opts = {}
    if type(severity) == "string" then
        jump_opts.severity = vim.diagnostic.severity[severity]
    end
    return function()
        jump_opts.count = dir and vim.v.count1 or -vim.v.count1
        vim.diagnostic.jump(jump_opts)
    end
end

return M
