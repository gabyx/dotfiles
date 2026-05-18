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
  },
  { "mfussenegger/nvim-treehopper", dependencies = { "smoka7/hop.nvim" } },
}
