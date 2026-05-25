---@class gabyx.buffer
local M = {}

local settings = require("gabyx.settings")

--- Check if a buffer is valid
---@param bufnr? integer The buffer to check, default to current buffer
---@return boolean # Whether the buffer is valid or not
function M.is_valid(bufnr)
    if not bufnr then
        bufnr = 0
    end
    return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted
end

local large_buf_cache, buf_size_cache = {}, {} -- cache large buffer detection results and buffer sizes
--- Check if a buffer is a large buffer (always returns false if large buffer detection is disabled)
---@param bufnr? integer the buffer to check the size of, default to current buffer
---@param large_buf_opts? LargeBugCfg large buffer parameters, default to AstroCore configuration
---@return boolean is_large whether the buffer is detected as large or not
function M.is_large(bufnr, large_buf_opts)
    if not bufnr then
        bufnr = vim.api.nvim_get_current_buf()
    end
    -- always return not large until buffer is loaded, do not cache decision
    if not vim.api.nvim_buf_is_loaded(bufnr) then
        return false
    end
    local skip_cache = large_buf_opts ~= nil -- skip cache when called manually with custom options

    if not large_buf_opts then
        large_buf_opts = settings.large_buf_opts
    end

    if skip_cache or large_buf_cache[bufnr] == nil then
        local enabled = vim.tbl_get(large_buf_opts, "enabled")

        if type(enabled) == "function" then
            large_buf_opts = vim.deepcopy(large_buf_opts)
            enabled = enabled(bufnr, large_buf_opts)
            if type(enabled) == "table" then
                large_buf_opts = enabled
            end
        end

        local large_buf = false
        if vim.F.if_nil(enabled, true) then
            if not buf_size_cache[bufnr] then
                local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
                buf_size_cache[bufnr] = ok and stats and stats.size or 0
            end

            local file_size = buf_size_cache[bufnr]
            local line_count = vim.api.nvim_buf_line_count(bufnr)
            local too_large = large_buf_opts.size and file_size > large_buf_opts.size
            local too_long = large_buf_opts.lines and line_count > large_buf_opts.lines
            local too_wide = large_buf_opts.line_length and (file_size / line_count) - 1 > large_buf_opts.line_length

            large_buf = too_large or too_long or too_wide or false
        end
        if skip_cache then
            return large_buf
        end
        large_buf_cache[bufnr] = large_buf
    end
    return large_buf_cache[bufnr]
end

return M
