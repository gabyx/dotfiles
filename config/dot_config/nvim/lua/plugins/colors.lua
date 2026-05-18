return {
  {
    "AstroNvim/astrotheme",
    config = function()
      require("astrotheme").setup({
        palette = "astrodark", -- String of the default palette to use when calling `:colorscheme astrotheme`
        background = { -- :h background, palettes to use when using the core vim background colors
          light = "astrolight",
          dark = "astrodark",
        },

        style = {
          transparent = false, -- Bool value, toggles transparency.
          inactive = false, -- Bool value, toggles inactive window color.
          float = true, -- Bool value, toggles floating windows background colors.
          neotree = true, -- Bool value, toggles neo-trees background color.
          border = true, -- Bool value, toggles borders.
          title_invert = false, -- Bool value, swaps text and background colors.
          italic_comments = true, -- Bool value, toggles italic comments.
          simple_syntax_colors = true, -- Bool value, simplifies the amounts of colors used for syntax highlighting.
        },

        termguicolors = true, -- Bool value, toggles if termguicolors are set by AstroTheme.
        terminal_color = false, -- Bool value, toggles if terminal_colors are set by AstroTheme.

        plugin_default = true, -- Sets how all plugins will be loaded
        -- "auto": Uses lazy / packer enabled plugins to load highlights.
        -- true: Enables all plugins highlights.
        -- false: Disables all plugins.

        palettes = {
          global = { -- Globally accessible palettes, theme palettes take priority.
            keyword_color = "#1166ab",
          },
        },

        highlights = {
          astrodark = {
            -- first parameter is the highlight table and the second parameter is the color palette table
            modify_hl_groups = function(hl, c) -- modify_hl_groups function allows you to modify hl groups,
              hl.Keyword.fg = c.keyword_color
              hl.Keyword.bold = true

              -- Do not highlight the scope indentation.
              hl.IblScope = { fg = c.ui.none_text }
            end,
          },
        },
      })
    end,
  },
}
