local M = {}

M.exists = function(path)
  local stat = vim.loop.fs_stat(path)
  return stat ~= nil
end

M.get_nixos_flake_url = function()
  local path = vim.fs.normalize("~/.local/share/chezmoi")
  print("Flake path:", path)
  if not M.exists(path) then
    return nil
  end

  return "git+file://" .. path
end

return M
