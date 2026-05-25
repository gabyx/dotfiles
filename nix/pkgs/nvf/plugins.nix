{
  config,
  lib,
  pkgs,
  ...
}:
{
  vim.extraPlugins = {
    "astrotheme" = {
      package = pkgs.vimPlugins.astrotheme;
      setup = # lua
        ''
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

          vim.cmd.colorscheme("astrotheme")
        '';
    };

    # "astroui" = {
    #   package = pkgs.vimPlugins.astroui;
    #   setup =
    #     # lua
    #     ''
    #       opts = {
    #         -- change colorscheme
    #         colorscheme = "astrodark",
    #
    #         folding = {
    #            enabled = function(bufnr) return gabyx.buffer.is_valid(bufnr) end,
    #            methods = { "lsp", "treesitter", "indent" },
    #         },
    #
    #         highlights = {
    #             init = {},
    #             astrotheme = {},
    #         },
    #
    #         status = {
    #             providers = {
    #                 lsp_client_names = {
    #                     mappings = {
    #                         typos_lsp = "typos",
    #                         lua_lsp = "lua",
    #                     },
    #                 },
    #             },
    #         },
    #
    #         icons = ${lib.generators.toLua { } config.gabyx.icons},
    #
    #         text_icons = {
    #           ActiveLSP = "LSP:",
    #           ArrowLeft = "<",
    #           ArrowRight = ">",
    #           BufferClose = "x",
    #           DapBreakpoint = "B",
    #           DapBreakpointCondition = "C",
    #           DapBreakpointRejected = "R",
    #           DapLogPoint = "L",
    #           DapStopped = ">",
    #           DefaultFile = "[F]",
    #           DiagnosticError = "X",
    #           DiagnosticHint = "?",
    #           DiagnosticInfo = "i",
    #           DiagnosticWarn = "!",
    #           Ellipsis = "...",
    #           Environment = "Env:",
    #           FileModified = "*",
    #           FileReadOnly = "[lock]",
    #           FoldClosed = "+",
    #           FoldOpened = "-",
    #           FoldSeparator = " ",
    #           FolderClosed = "[D]",
    #           FolderEmpty = "[E]",
    #           FolderOpen = "[O]",
    #           GitAdd = "[+]",
    #           GitChange = "[/]",
    #           GitConflict = "[!]",
    #           GitDelete = "[-]",
    #           GitIgnored = "[I]",
    #           GitRenamed = "[R]",
    #           GitSign = "|",
    #           GitStaged = "[S]",
    #           GitUnstaged = "[U]",
    #           GitUntracked = "[?]",
    #           MacroRecording = "Recording:",
    #           Paste = "[PASTE]",
    #           Search = "?",
    #           Selected = "*",
    #           Spellcheck = "[SPELL]",
    #           TabClose = "X",
    #         },
    #
    #         lazygit = {
    #           theme = {
    #             [241] = { fg = "Special" },
    #             activeBorderColor = { fg = "MatchParen", bold = true },
    #             cherryPickedCommitBgColor = { bg = "Substitute" },
    #             cherryPickedCommitFgColor = { fg = "Substitute" },
    #             defaultFgColor = { fg = "Normal" },
    #             inactiveBorderColor = { fg = "FloatBorder" },
    #             markedBaseCommitBgColor = { bg = "CurSearch" },
    #             markedBaseCommitFgColor = { fg = "CurSearch" },
    #             optionsTextColor = { fg = "Function" },
    #             searchingActiveBorderColor = { fg = "MatchParen", bold = true },
    #             selectedLineBgColor = { bg = "Visual" }, -- set to `default` to have no background colour
    #             unstagedChangesColor = { fg = "DiagnosticError" },
    #           },
    #         }
    #       }
    #
    #       require("astroui").setup(opts)
    #     '';
    # };
  };

  vim = {
    additionalRuntimePaths = [
      ./config
    ];

    luaConfigRC.gabyx =
      lib.nvim.dag.entryBefore [ "pluginConfigs" ]
        # Lua
        ''
          local gabyx = {}
          gabyx.buffer = require("gabyx.buffer")
        '';
  };
}
