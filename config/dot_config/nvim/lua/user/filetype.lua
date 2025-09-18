local stripAndRematch = function(ext, path, bufnr)
    local stripped = vim.fn.fnamemodify(path, ":r") -- test.json.<ext> -> test.json
    ext = vim.fn.fnamemodify(stripped, ":e") -- extension: .json
    if ext then
        return vim.filetype.match({ filename = "x." .. ext })
    end
    return nil
end

-- Filetype mappings which are not autodetected.
vim.filetype.add({
    extension = {
        tmpl = function(path, bufnr)
            return stripAndRematch("tmpl", path, bufnr)
        end,
        tmp = function(path, bufnr)
            return stripAndRematch("tmp", path, bufnr)
        end,
    },
    filename = {
        ["Tiltfile"] = "tiltfile",
        ["justfile"] = "just",
    },
    pattern = {},
})
