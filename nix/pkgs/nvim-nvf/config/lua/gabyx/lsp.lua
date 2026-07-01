local M = {}

local gabyx = require("gabyx")

-- Start the LSP over `startExe`.
--- @param startExe string
--- @param lspExe string
--- @param lspExeFallback string
--- @param args string[]
M.start = function(dispatchers, startExe, lspExe, lspExeFallback, args)
    local exe = vim.fn.exepath(lspExe)

    if exe == "" then
        exe = lspExeFallback

        if vim.fn.executable(exe) == 0 then
            gabyx.notify(
                string.format("[lsp] Could not resolve '%s' on PATH or baked path '%s'.", lspExe, lspExeFallback),
                vim.log.levels.ERROR
            )

            return nil
        end

        gabyx.notify(
            string.format("[lsp] Could not find '%s' in PATH; using baked '%s'.", lspExe, lspExeFallback),
            vim.log.levels.WARN
        )
    end

    local cmd = vim.list_extend({ startExe, exe }, args)
    gabyx.notify(string.format("[lsp] Starting lsp '%s'", vim.inspect(cmd)), vim.log.levels.INFO)

    return vim.lsp.rpc.start(cmd, dispatchers)
end

return M
