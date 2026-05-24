---@type LazySpec
return {
  -- Treesitter setup.
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      treesitter = {
        highlight = true, -- enable/disable treesitter based highlighting
        indent = true, -- enable/disable treesitter based indentation
        auto_install = false, -- enable/disable automatic installation of detected languages
        ensure_installed = {
          "regex",
          "lua",
          "rust",
          "toml",
          "python",
          "c",
          "html",
          "css",
          "javascript",
          "json",
          "go",
          "gomod",
          "gosum",
          "gowork",
          "cmake",
          "cpp",
          "dockerfile",
          "bash",
          "starlark",
          "markdown",
          "markdown_inline",
        },
      },
    },

    keys = {
      { "<Leader>uT", ":TSContext toggle<cr>", desc = "Treesitter context toggle." },
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
