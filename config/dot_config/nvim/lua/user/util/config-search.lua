local M = {}
local lsputil = require("lspconfig.util")

-- Taken from `lspconfig.util`. Search ancestor paths and return
-- the result of the closure if its a match.
function M.search_ancestors(startpath, func)
    vim.validate({ func = { func, "f" } })

    if func(startpath) then
        return startpath
    end
    local guard = 100
    for path in lsputil.path.iterate_parents(startpath) do
        -- Prevent infinite recursion if our algorithm breaks
        guard = guard - 1
        if guard == 0 then
            return
        end

        local res = func(path)
        if res then
            return res
        end
    end
end

-- Returns the config file by searching upwards for patterns `...`
-- Usage: `search_config_file(path, unpack({".clang-for*", "other*"}))`
function M.search_parents(startpath, ...)
    local patterns = vim.iter({ ... }):flatten():totable()

    for _, pattern in ipairs(patterns) do
        local match = M.search_ancestors(startpath, function(path)
            for _, p in ipairs(vim.fn.glob(lsputil.path.join(lsputil.path.escape_wildcards(path), pattern), true, true)) do
                if lsputil.path.exists(p) then
                    return p
                end
            end
        end)

        if match ~= nil then
            return match
        end
    end
end

return M
