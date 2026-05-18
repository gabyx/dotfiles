local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local M = {
  format_on_save = true,
  augroup = "mhartington-format-on-save",
}

M.enable_format_on_save = function()
  augroup(M.augroup, { clear = true })
  autocmd("BufWritePost", {
    group = M.augroup,
    command = ":FormatWrite",
  })

  M.format_on_save = true
end

M.disable_format_on_save = function()
  vim.api.nvim_del_augroup_by_name(M.augroup)
  M.format_on_save = false
end

M.toggle_format_on_save = function()
  if M.format_on_save then
    M.disable_format_on_save()
    vim.notify("Format on save disabled.", vim.log.levels.INFO)
  else
    M.enable_format_on_save()
    vim.notify("Format on save enabled.", vim.log.levels.INFO)
  end
end

return M
