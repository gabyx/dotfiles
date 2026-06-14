local M = {}

M.quit = function()
    local modified = vim.tbl_filter(function(b)
        return vim.api.nvim_buf_is_loaded(b) and vim.bo[b].modified and vim.bo[b].buflisted
    end, vim.api.nvim_list_bufs())

    if #modified == 0 then
        vim.cmd.qall()
        return
    end

    vim.ui.select(
        { "Cancel.", "Save all and quit.", "Discard and quit." },
        { prompt = string.format("Unsaved changes in '%d' buffer(s):", #modified) },
        function(choice)
            if choice == "Save all and quit." then
                vim.cmd("wqall")
            elseif choice == "Discard and quit." then
                vim.cmd("qall!")
            end
        end
    )
end

return M
