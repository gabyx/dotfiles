---@type LazySpec
return {
  -- Treesitter setup.
  { "nvim-treesitter/nvim-treesitter", enabled = false },
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      treesitter = {
        highlight = true, -- enable/disable treesitter based highlighting
        indent = true, -- enable/disable treesitter based indentation
        auto_install = false, -- enable/disable automatic installation of detected languages
        ensure_installed = {
          -- "regex",
          -- "lua",
          -- "rust",
          -- "toml",
          -- "python",
          -- "c",
          -- "html",
          -- "css",
          -- "javascript",
          -- "json",
          -- "go",
          -- "gomod",
          -- "gosum",
          -- "gowork",
          -- "cmake",
          -- "cpp",
          -- "dockerfile",
          -- "bash",
          -- "starlark",
          -- "markdown",
          -- "markdown_inline",
        },
      },
    },

    keys = {
      { "<Leader>uT", ":TSContext toggle<cr>", desc = "Treesitter context toggle." },
    },
  },

  -- Treesitter selection.
  {
    "shushtain/incselect.nvim",
    keys = {
      {
        "<CR>",
        function()
          require("incselect").init()
        end,
        mode = "n",
      },
      {
        "<CR>",
        function()
          require("incselect").parent()
        end,
        mode = "x",
      },
      {
        "<BS>",
        function()
          require("incselect").child()
        end,
        mode = "x",
      },
    },
  },

  -- Hop around in Treesitter tree.
  {
    "mfussenegger/nvim-treehopper",
    dependencies = { "smoka7/hop.nvim" },
    keys = {
      {
        "<Leader>ja",
        function()
          require("tsht").nodes()
        end,
        desc = "Select in AST.",
      },
      {
        "<Leader>jA",
        function()
          require("tsht").move()
        end,
        desc = "Move in AST.",
      },
    },
  },
}
