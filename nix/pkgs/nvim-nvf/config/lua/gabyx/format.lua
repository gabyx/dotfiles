local M = {}

local on_save

M.enable_on_save = function()
    on_save = true
    vim.notify("Format on save enabled.", vim.log.levels.INFO)
end

M.disable_on_save = function()
    on_save = false
    vim.notify("Format on save disabled.", vim.log.levels.INFO)
end

M.toggle_on_save = function()
    if on_save then
        M.disable_on_save()
    else
        M.enable_on_save()
    end
end

M.on_save_enabled = function()
    return on_save
end

return M
