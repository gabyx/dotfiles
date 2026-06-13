local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local extras = require("luasnip.extras")
local rep = extras.rep
local fmt = require("luasnip.extras.fmt").fmt
local c = ls.choice_node
local f = ls.function_node
local d = ls.dynamic_node

local function get_clibboard_buffer()
  local cp = vim.fn.getreg()
  if cp ~= nil then
    local lines = {}
    for s in cp:gmatch("[^\r\n]+") do
      table.insert(lines, s)
    end
    return lines
  else
    return ""
  end
end

-- Compute the second column size depending on the first.
local function compute_cols_size(args)
  -- args = {{ "input-1" }}
  local width = args[1][1]
  local number = tonumber(width)

  if number == nil then
    width = 50
  end

  return tostring(100 - width)
end

-- stylua: ignore
ls.add_snippets("markdown", {
  s("cols2", {
    t({"::::::{.columns}","",""}),
    t({':::{.column width="'}), i(1), t({'%"}',"",""}),
    i(2),
    t({"","",":::","",""}),
    t({':::{.column width="'}), f(compute_cols_size, {1}, {}), t({'%"}',"", ""}),
    i(3),
    t({"","",":::","", ""}),
    t({"::::::"}),
  }),
  s("div", {
    t({"::: {"}), i(1), t({"}", "", ""}),
    f(get_clibboard_buffer),
    i(2),
    t({"", "", ":::"}),
  }),
})
