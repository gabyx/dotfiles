{ pkgs, ... }:
{

  # TODO:
  # Plugins of AstroNvim https://github.com/AstroNvim/AstroNvim/tree/main/lua/astronvim/plugins

  vim.extraPlugins = {

    # TODO: not the way, but whats the workaround, probably impossible...
    "lazy" = {
      package = pkgs.vimPlugins.lazy-nvim;
      setup = ''
        require("lazy").setup({})
      '';
    };

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

    "astrocore" = {
      package = pkgs.vimPlugins.astrocore;
      after = [
        "lazy"
        "astrotheme"
        "astroui"
      ];
      setup =
        # lua
        ''
          print("setup astrocore")
          opts = {
            -- Configure core features of AstroNvim
            features = {
                large_buf = { size = 1024 * 500, lines = 100000 }, -- set global limits for large files for disabling features like treesitter
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
          }

          require("astrocore").setup(opts)
        '';
    };

    "astroui" = {
      package = pkgs.vimPlugins.astroui;
      setup =
        # lua
        ''
          print("setup astroui")
          opts = {
            -- change colorscheme
            colorscheme = "astrodark",
            -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
            highlights = {
                init = {},
                astrotheme = {},
            },

            status = {
                providers = {
                    lsp_client_names = {
                        mappings = {
                            typos_lsp = "typos",
                            lua_lsp = "lua",
                        },
                    },
                },
            },
            -- Icons can be configured throughout the interface
            icons = {
                -- configure the loading of the lsp in the status line
                LSPLoading1 = "⠋",
                LSPLoading2 = "⠙",
                LSPLoading3 = "⠹",
                LSPLoading4 = "⠸",
                LSPLoading5 = "⠼",
                LSPLoading6 = "⠴",
                LSPLoading7 = "⠦",
                LSPLoading8 = "⠧",
                LSPLoading9 = "⠇",
                LSPLoading10 = "⠏",
            },
          }

          require("astroui").setup(opts)
        '';
    };
  };

  vim = {
    additionalRuntimePaths = [
      ./config
    ];

    luaConfigRC.gabyx = ''
      require('gabyx-pure')
    '';

    autopairs.nvim-autopairs.enable = true;

    filetree = {
      neo-tree = {
        enable = true;
      };
    };
  };
}
