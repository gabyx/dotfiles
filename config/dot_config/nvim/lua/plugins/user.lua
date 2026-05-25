return {
  -- Local Project Configuration
  {
    lazy = false,
    "klen/nvim-config-local",
    opts = {
      -- Config file patterns to load (lua supported)
      config_files = { ".nvim/nvim.lua" },

      -- Where the plugin keeps files data
      hashfile = vim.fn.stdpath("data") .. "/nvim-config-local",

      autocommands_create = true, -- Create autocommands (VimEnter, DirectoryChanged)
      commands_create = true, -- Create commands (ConfigLocalSource, ConfigLocalEdit, ConfigLocalTrust, ConfigLocalIgnore)
      silent = false, -- Disable plugin messages (Config loaded/ignored)
      lookup_parents = true, -- Lookup config files in parent directories
    },
  },
  -- See keystrokes with `KeysToggles`
  {
    "tamton-aquib/keys.nvim",
    lazy = false,
    opts = {
      enable_on_startup = false,
    },
  },
  -- Visual whitespaces.
  {
    "mcauley-penney/visual-whitespace.nvim",
    config = true,
    event = "ModeChanged *:[vV\22]", -- optionally, lazy load on entering visual mode
    opts = {},
  },
  -- Adding some nice searchline/cmdline.
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = true, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
    },
  },
  {
    "eandrju/cellular-automaton.nvim",
    keys = {
      {
        "<Leader>sff",
        ":CellularAutomaton make_it_rain<cr>",
        desc = "Make letters falling.",
      },
    },
  },
}
