require("lazy").setup({
    {
        "AstroNvim/AstroNvim",
        version = "^5", -- Remove version tracking to elect for nightly AstroNvim

        -- If `pin_plugins` is used then astronvim uses
        -- a snapshot to set the plugin references
        -- https://github.com/AstroNvim/AstroNvim/blob/main/lua/astronvim/lazy_snapshot.lua

        import = "astronvim.plugins",
        opts = { -- AstroNvim options must be set here with the `import` key
            mapleader = " ", -- This ensures the leader key must be configured before Lazy is set up
            maplocalleader = ",", -- This ensures the localleader key must be configured before Lazy is set up
            icons_enabled = true, -- Set to false to disable icons (if no Nerd Font is available)
            pin_plugins = false, -- Default will pin plugins when tracking `version` of AstroNvim, set to true/false to override
            update_notifications = true, -- Enable/disable notification about running `:Lazy update` twice to update pinned plugins
        },
    },
    -- Make sure we use the commit from nixpkgs that is compatible with our grammars.
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        commit = vim.fn.readfile(vim.fn.stdpath("config") .. "/.treesitter-rev", "", 1)[1],
    },
    -- Make sure we use the commit from nixpkgs that is compatible with our grammars.
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        commit = "4d55f63252e04c5212daed958e4e940915ff16ce",
    },
    { import = "community" },
    { import = "plugins" },
} --[[@as LazySpec]], {
    -- Configure any other `lazy.nvim` configuration options here
    install = { colorscheme = { "astrotheme", "habamax" } },
    ui = { backdrop = 100 },
    performance = {
        rtp = {
            -- disable some rtp plugins, add more to your liking
            disabled_plugins = {
                "gzip",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "zipPlugin",
            },
        },
    },
} --[[@as LazyConfig]])
