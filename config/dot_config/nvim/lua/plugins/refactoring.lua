return {
  -- Use the awesome refactoring library.
  {
    "ThePrimeagen/refactoring.nvim",
    name = "refactoring",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  }, --

  -- Use the python refactoring library
  -- {
  --   "python-rope/ropevim",
  --   enable = false,
  --   run = "pip install ropevim",
  -- },
}
