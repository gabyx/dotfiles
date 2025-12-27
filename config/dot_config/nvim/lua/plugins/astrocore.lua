-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
        -- Configure core features of AstroNvim
        features = {
            large_buf = { size = 1024 * 500, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
            autopairs = true, -- enable autopairs at start
            cmp = true, -- enable completion at start
            diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
            highlighturl = true, -- highlight URLs at start
            notifications = true, -- enable notifications at start
        },
        -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
        diagnostics = {
            virtual_text = true,
            underline = true,
        },
        -- vim options can be configured here
        options = {
            opt = { -- vim.opt.<key>
                relativenumber = true, -- sets vim.opt.relativenumber
                number = true, -- sets vim.opt.number
                spell = false, -- sets vim.opt.spell
                signcolumn = "auto", -- sets vim.opt.signcolumn to auto
                wrap = false, -- sets vim.opt.wrap

                -- Treesitter folding
                foldmethod = "expr",
                foldexpr = "nvim_treesitter#foldexpr()",
                -- Whitespace Characters
                listchars = "tab:▷ ,trail:·,extends:◣,precedes:◢,nbsp:○",
                list = true,
                -- Auto-reload files when modified externally
                -- https://unix.stackexchange.com/a/383044
                autoread = true,
                -- Do not conceal anything in files
                -- (markdown code blocks as example).
                conceallevel = 0,

                diffopt = "internal,anchor,filler,closeoff,linematch:40,algorithm:histogram,linematch:60",
            },
            g = { -- vim.g.<key>
                -- configure global vim variables (vim.g)
                -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
                -- This can be found in the `lua/lazy_setup.lua` file
            },
        },
        -- Mappings can be configured through AstroCore as well.
        -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    },
    -- Configure neo-tree.
    {
        "nvim-neo-tree/neo-tree.nvim",
        opts = {
            filesystem = {
                filtered_items = {
                    visible = true,
                    hide_dotfiles = false,
                    hide_gitignored = false,
                    never_show = {
                        ".DS_Store",
                        ".git",
                    },
                },
            },
        },
    },
    {
        "folke/snacks.nvim",
        opts = {
            notifier = {
                timeout = 1000,
            },

            -- Wrap words in picker right panel.
            win = { preview = { wo = { wrap = true } } },
        },
    },
}
