return {
    -- Treesitter setup.
    {
        "nvim-treesitter/nvim-treesitter",
        build = "nvim-treesitter-install",
        opts = {
            -- ensure_installed = {
            --     "regex",
            --     "lua",
            --     "rust",
            --     "toml",
            --     "python",
            --     "c",
            --     "html",
            --     "css",
            --     "javascript",
            --     "json",
            --     "go",
            --     "gomod",
            --     "gosum",
            --     "gowork",
            --     "cmake",
            --     "cpp",
            --     "dockerfile",
            --     "bash",
            --     "starlark",
            --     "markdown",
            --     "markdown_inline",
            -- },
            -- sync_install = false,
            -- auto_install = false,

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
}
