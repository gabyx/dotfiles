---@type LazySpec
return {
  -- Typescript LSP
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
  },
  -- CPP clangd extension.
  -- {
  --   "p00f/clangd_extensions.nvim",
  --   pin = true,
  --   init = function()
  --     -- load clangd extensions when clangd attaches
  --     local augroup = vim.api.nvim_create_augroup("clangd_extensions", { clear = true })
  --     vim.api.nvim_create_autocmd("LspAttach", {
  --       group = augroup,
  --       desc = "Load clangd_extensions with clangd",
  --       callback = function(args)
  --         if assert(vim.lsp.get_client_by_id(args.data.client_id)).name == "clangd" then
  --           require("clangd_extensions")
  --           -- add more `clangd` setup here as needed such as loading autocmds
  --           vim.api.nvim_del_augroup_by_id(augroup) -- delete auto command since it only needs to happen once
  --         end
  --       end,
  --     })
  --   end,
  -- },
  -- {
  --   "mrcjkb/rustaceanvim",
  --   version = "^6", -- Recommended
  --   lazy = false, -- This plugin is already lazy
  --   opts = function()
  --     -- Ref: https://github.com/AstroNvim/astrocommunity/blob/main/lua/astrocommunity/pack/rust/init.lua
  --     local astrolsp_avail, astrolsp = pcall(require, "astrolsp")
  --     local astrolsp_opts = (astrolsp_avail and astrolsp.lsp_opts("rust_analyzer")) or {}
  --     local server = {
  --       ---@type table | (fun(project_root:string|nil, default_settings: table|nil):table) -- The rust-analyzer settings or a function that creates them.
  --       settings = function(project_root, default_settings)
  --         local astrolsp_settings = astrolsp_opts.settings or {}
  --
  --         local merge_table = require("astrocore").extend_tbl(default_settings or {}, astrolsp_settings)
  --         local ra = require("rustaceanvim.config.server")
  --         -- load_rust_analyzer_settings merges any found settings with the passed in default settings table and then returns that table
  --         return ra.load_rust_analyzer_settings(project_root, {
  --           settings_file_pattern = "rust-analyzer.json",
  --           default_settings = merge_table,
  --         })
  --       end,
  --     }
  --     local final_server = require("astrocore").extend_tbl(astrolsp_opts, server)
  --     return {
  --       server = final_server,
  --     }
  --   end,
  --   config = function(_, opts)
  --     vim.g.rustaceanvim = require("astrocore").extend_tbl(opts, vim.g.rustaceanvim)
  --   end,
  -- },
}
