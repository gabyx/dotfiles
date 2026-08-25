-- Load additional filetypes.
require("user.filetype")

-- Load autocmds.
require("user.autocmds")

-- Load local project configuration.
require("config-local").source()

-- Load all lua snippets.
require("user.snippets.all")
