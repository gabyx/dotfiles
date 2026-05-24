---@type LazySpec
return {
  -- Trouble shows all diagnostics in a common window
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    lazy = true,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { auto_preview = false, focus = true },
    keys = {
      { "<Leader>xx", ":Trouble diagnostics toggle<cr>", desc = "Toggle trouble diagnostics." },
    },
  },
}
