---@type LazySpec
return {
  {
    "mbbill/undotree",
    lazy = false,
    keys = {
      {
        "<Leader>bu",
        function()
          vim.cmd.UndotreeToggle()
        end,
        desc = "Show Undo Tree",
      },
    },
  },

  -- Only used with Tmux setup.
  -- {
  --   "alexghergh/nvim-tmux-navigation",
  --   lazy = false,
  --   pin = true,
  --   opts = {
  --     disable_when_zoomed = true,
  --     keybindings = {
  --       left = "<C-h>",
  --       down = "<C-j>",
  --       up = "<C-k>",
  --       right = "<C-l>",
  --       last_active = "<C-\\>",
  --       next = "<C-Space>",
  --     },
  --   },
  -- },

  -- Smart Splits to Switch between Neovim and Multiplexer.
  { "mrjones2014/smart-splits.nvim", version = ">=1.0.0", lazy = false },

  -- Move Plugin
  {
    "booperlv/nvim-gomove",
    lazy = false,
    opts = {
      -- whether or not to map default key bindings, (true/false)
      map_defaults = false,
      -- whether or not to reindent lines moved vertically (true/false)
      reindent = true,
      -- whether or not to undojoin same direction moves (true/false)
      undojoin = true,
      -- whether to not to move past end column when moving blocks horizontally, (true/false)
      move_past_end_col = false,
    },

    keys = {
      { "<S-Left>", "<Plug>GoNSMLeft", remap = false, mode = "n" },
      { "<S-Up>", "<Plug>GoNSMUp", remap = false, mode = "n" },
      { "<S-Down>", "<Plug>GoNSMDown", remap = false, mode = "n" },
      { "<S-Right>", "<Plug>GoNSMRight", remap = false, mode = "n" },
      { "<S-C-Left>", "<Plug>GoNSDLeft", remap = false, mode = "n" },
      { "<S-C-Down>", "<Plug>GoNSDDown", remap = false, mode = "n" },
      { "<S-C-Up>", "<Plug>GoNSDUp", remap = false, mode = "n" },
      { "<S-C-Right>", "<Plug>GoNSDRight", remap = false, mode = "n" },

      { "<S-Left>", "<Plug>GoVSMLeft", remap = false, mode = "x" },
      { "<S-Down>", "<Plug>GoVSMDown", remap = false, mode = "x" },
      { "<S-Up>", "<Plug>GoVSMUp", remap = false, mode = "x" },
      { "<S-Right>", "<Plug>GoVSMRight", remap = false, mode = "x" },
      { "<S-C-Left>", "<Plug>GoVSDLeft", remap = false, mode = "x" },
      { "<S-C-Down>", "<Plug>GoVSDDown", remap = false, mode = "x" },
      { "<S-C-Up>", "<Plug>GoVSDUp", remap = false, mode = "x" },
      { "<S-C-Right>", "<Plug>GoVSDRight", remap = false, mode = "x" },
    },
  },

  {
    "ThePrimeagen/harpoon",
    lazy = false,
    keys = {
      {
        "<Leader>jf",
        ':lua require("harpoon.ui").toggle_quick_menu()<CR>',
        mode = { "n", "v" },
        desc = "Harpoon list.",
      },
      {
        "<Leader>jj",
        ':lua require("harpoon.mark").add_file()<CR>',
        mode = { "n", "v" },
        desc = "Add to harpoon list.",
      },
      {
        "<S-h>",
        ':lua require("harpoon.ui").nav_next()<CR>',
        mode = { "n", "v" },
        desc = "Next harpoon file.",
      },
      {
        "<S-l>",
        ':lua require("harpoon.ui").nav_prev()<CR>',
        mode = { "n", "v" },
        desc = "Previous harpoon file.",
      },
    },
  },

  {
    "chentoast/marks.nvim",
    lazy = false,
    opts = {
      -- whether to map keybinds or not. default true
      default_mappings = true,
      -- which builtin marks to show. default {}
      builtin_marks = { "a", "b", "d", "f" },
      -- whether movements cycle back to the beginning/end of buffer. default true
      cyclic = true,
      -- whether the shada file is updated after modifying uppercase marks. default false
      force_write_shada = false,
      -- how often (in ms) to redraw signs/recompute mark positions.
      -- higher values will have better performance but may cause visual lag,
      -- while lower values may cause performance penalties. default 150.
      refresh_interval = 250,
      -- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
      -- marks, and bookmarks.
      -- can be either a table with all/none of the keys, or a single number, in which case
      -- the priority applies to all marks.
      -- default 10.
      sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
      -- disables mark tracking for specific filetypes. default {}
      excluded_filetypes = {},
      -- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
      -- sign/virttext. Bookmarks can be used to group together positions and quickly move
      -- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
      -- default virt_text is "".
      bookmark_0 = {
        sign = "⚑",
        annotate = false,
      },
    },
  },

  -- Hop around
  {
    "smoka7/hop.nvim",
    version = "v2.5.0",
    opts = {},
    lazy = false,
    keys = {
      { "<Leader>jk", ":HopWord<CR>", desc = "Hop words.", mode = { "n", "v" } },
      { "<Leader>jh", ":HopLine<CR>", desc = "Hop lines.", mode = { "n", "v" } },
    },
  },

  -- Surround plugin to easily replace brackets and other shit.
  {
    "kylechui/nvim-surround",
    version = "2.1.5", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end,
  },
}
