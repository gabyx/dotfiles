return {
    {
        "mrcjkb/rustaceanvim",
        version = "^6", -- Recommended
        lazy = false, -- This plugin is already lazy
        opts = function()
            -- Ref: https://github.com/AstroNvim/astrocommunity/blob/main/lua/astrocommunity/pack/rust/init.lua
            local astrolsp_avail, astrolsp = pcall(require, "astrolsp")
            local astrolsp_opts = (astrolsp_avail and astrolsp.lsp_opts("rust_analyzer")) or {}
            local server = {
                ---@type table | (fun(project_root:string|nil, default_settings: table|nil):table) -- The rust-analyzer settings or a function that creates them.
                settings = function(project_root, default_settings)
                    local astrolsp_settings = astrolsp_opts.settings or {}

                    local merge_table = require("astrocore").extend_tbl(default_settings or {}, astrolsp_settings)
                    local ra = require("rustaceanvim.config.server")
                    -- load_rust_analyzer_settings merges any found settings with the passed in default settings table and then returns that table
                    return ra.load_rust_analyzer_settings(project_root, {
                        settings_file_pattern = "rust-analyzer.json",
                        default_settings = merge_table,
                    })
                end,
            }
            local final_server = require("astrocore").extend_tbl(astrolsp_opts, server)
            return {
                server = final_server,
            }
        end,
        config = function(_, opts)
            vim.g.rustaceanvim = require("astrocore").extend_tbl(opts, vim.g.rustaceanvim)
        end,
    },
    {
        "mbbill/undotree",
        lazy = false,
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
    -- Markdown plugins.
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && yarn install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        lazy = false,
    },
    -- Cpp plugins
    { "Civitasv/cmake-tools.nvim" },
    { "p00f/clangd_extensions.nvim", pin = true },
    -- See keystrokes
    {
        "tamton-aquib/keys.nvim",
        lazy = false,
        opts = {
            enable_on_startup = false,
        },
    },
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
    },
    { "ThePrimeagen/harpoon", lazy = false },
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
    {
        "smoka7/hop.nvim",
        version = "v2.5.0",
        opts = {},
        lazy = false,
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
    -- Visual whitespaces.
    {
        "mcauley-penney/visual-whitespace.nvim",
        config = true,
        event = "ModeChanged *:[vV\22]", -- optionally, lazy load on entering visual mode
        opts = {},
    },
    -- Diff view plugin.
    {
        lazy = true,
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewFileHistory" },
        opts = function(_, opts)
            local actions = require("diffview.actions")
            return vim.tbl_deep_extend("force", opts, {
                keymaps = {
                    view = {
                        -- The `view` bindings are active in the diff buffers, only when the current
                        -- tabpage is a Diffview.
                        {
                            "n",
                            "<leader>to",
                            actions.conflict_choose("ours"),
                            { desc = "Choose the OURS version of a conflict" },
                        },
                        {
                            "n",
                            "<leader>tt",
                            actions.conflict_choose("theirs"),
                            { desc = "Choose the THEIRS version of a conflict" },
                        },
                        {
                            "n",
                            "<leader>tb",
                            actions.conflict_choose("base"),
                            { desc = "Choose the BASE version of a conflict" },
                        },
                        {
                            "n",
                            "<leader>ta",
                            actions.conflict_choose("all"),
                            { desc = "Choose all the versions of a conflict" },
                        },
                        {
                            "n",
                            "<leader>tO",
                            actions.conflict_choose_all("ours"),
                            { desc = "Choose the OURS version of a conflict for the whole file" },
                        },
                        {
                            "n",
                            "<leader>tT",
                            actions.conflict_choose_all("theirs"),
                            { desc = "Choose the THEIRS version of a conflict for the whole file" },
                        },
                        {
                            "n",
                            "<leader>tB",
                            actions.conflict_choose_all("base"),
                            { desc = "Choose the BASE version of a conflict for the whole file" },
                        },
                        {
                            "n",
                            "<leader>tA",
                            actions.conflict_choose_all("all"),
                            { desc = "Choose all the versions of a conflict for the whole file" },
                        },
                    },
                },
            })
        end,
    },
    -- Trouble shows all diagnostics in a common window
    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        lazy = true,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = { auto_preview = false, focus = true },
    },
    {
        "nvim-pack/nvim-spectre",
        keys = {
            {
                "<Leader>sw",
                function()
                    require("spectre").open_visual({ select_word = true })
                end,
                desc = "Search current word.",
            },
            {
                "<Leader>sw",
                function()
                    require("spectre").open_visual()
                end,
                desc = "Search current word.",
                mode = "v",
            },
            {
                "<Leader>sp",
                function()
                    require("spectre").open_file_search({ select_word = true })
                end,
                desc = "Search current word in file.",
            },
            {
                "<Leader>sS",
                function()
                    require("spectre").toggle()
                end,
                desc = "Search with Spectre",
            },
        },
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
    -- Adding emoji completion.
    {
        "moyiz/blink-emoji.nvim",
        lazy = true,
        specs = {
            {
                "Saghen/blink.cmp",
                optional = true,
                opts = {
                    sources = {
                        -- enable the provider by default (automatically extends when merging tables)
                        default = { "emoji" },
                        providers = {
                            -- Specific details depend on the blink source
                            emoji = {
                                name = "Emoji",
                                module = "blink-emoji",
                                min_keyword_length = 1,
                                score_offset = -1,
                            },
                        },
                    },
                },
            },
        },
    },
}
