local M = {}

-- Quits nvim gracefully by confirming for all buffers.
M.quit = function()
    local modified = vim.tbl_filter(function(b)
        return vim.bo[b].modified and vim.bo[b].buflisted
    end, vim.api.nvim_list_bufs())

    local save_all = false
    for _, buf in ipairs(modified) do
        if save_all then
            vim.api.nvim_buf_call(buf, function()
                vim.cmd.write()
            end)
        else
            vim.api.nvim_set_current_buf(buf)
            vim.cmd.redraw()

            local name = vim.api.nvim_buf_get_name(buf)
            if name == "" then
                name = "[No Name]"
            end

            local choice =
                vim.fn.confirm(('Save changes to "%s"?\n'):format(name), "&Yes\n&No\nYes &All\n&Cancel", 1, "Question")

            if choice == 0 or choice == 4 then
                -- Cancel / Esc
                return
            elseif choice == 1 then
                -- Yes
                vim.api.nvim_buf_call(buf, function()
                    vim.cmd.write()
                end)
            elseif choice == 3 then
                -- Yes All
                save_all = true
                vim.api.nvim_buf_call(buf, function()
                    vim.cmd.write()
                end)
            end
        end
    end

    vim.cmd.quitall({ bang = true }) -- ! discards the buffers you said "No" to
end

return M
