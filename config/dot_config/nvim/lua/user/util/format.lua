local M = {}

local config_search = require("user.util.config-search")
local util = require("formatter.util")

M.sql_format = function()
  local config = config_search.search_parents(
    util.get_current_buffer_file_dir(),
    unpack({ "setup.cfg", "tox.ini", "pep8.ini", ".sqlfluff", "pyproject.toml" })
  )

  return {
    exe = "sqlfluff",
    args = {
      "format",
      "--disable-progress-bar",
      "--nocolor",
      "--config",
      config,
      "-",
    },
    stdin = true,
    ignore_exitcode = false,
  }
end

return M
