return {
    -- Treesitter setup.
    {
        "nvim-treesitter/nvim-treesitter",
        build = "nvim-treesitter-install",
        branch = "main",
        opts = {
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
            sync_install = false,
            auto_install = false,

            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            ident = { enable = true },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<CR>",
                    -- scope_incremental = "<S>",
                    node_incremental = "<CR>",
                    node_decremental = "<BS>",
                },
            },
            rainbow = {
                enable = true,
                extended_mode = true,
                max_file_lines = nil,
            },
            -- We use always a C++ compiler.
            -- install = {
            --   compiler = { vim.fn.getenv "CXX", "clang++", "g++" },
            -- },
        },
    },
    { "mfussenegger/nvim-treehopper", dependencies = { "smoka7/hop.nvim" } },
    -- Context lines to see on top where we are.
    {
        "nvim-treesitter/nvim-treesitter-context",
        lazy = false,
        opts = {
            multiline_threshold = 10,
        },
    },

    -- -- Justfile treesitter language until in main repo.
    -- {
    --     lazy = false,
    --     "IndianBoy42/tree-sitter-just",
    --     config = function()
    --         local configs = require("nvim-treesitter.parsers").get_parser_configs()
    --         configs["just"] = {
    --             install_info = {
    --                 url = "https://github.com/IndianBoy42/tree-sitter-just", -- local path or git repo
    --                 files = { "src/parser.c", "src/scanner.cc" },
    --                 branch = "main",
    --                 -- use_makefile = true -- this may be necessary on MacOS (try if you see compiler errors)
    --             },
    --             maintainers = { "@IndianBoy42" },
    --         }
    --
    --         require("tree-sitter-just").setup({})
    --     end,
    -- },
}
