-- Filetype mappings which are not autodetected.
vim.filetype.add({
    extension = {},
    filename = {
        ["Tiltfile"] = "tiltfile",
        ["justfile"] = "make",
    },
    pattern = {},
})

-- Load autocmds.
require("user.autocmds")

-- Load local project configuration.
require("config-local").source()

-- Load all lua snippets.
require("user.snippets.all")
