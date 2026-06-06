{
  pkgs,
  ...
}:
let
  heirline-components-nvim =
    (pkgs.vimUtils.buildVimPlugin {
      pname = "heirline-components.nvim";
      version = "2026-02-25";
      src = pkgs.fetchFromGitHub {
        owner = "Zeioth";
        repo = "heirline-components.nvim";
        rev = "5ea9a16286c01b7c36d58c91903d1f8ff0b7ddeb";
        sha256 = "0gij9c9qgmqc99fnqnvp6icxp32q0wkz536ric2x5vpbqlzsdkik";
      };
      meta.homepage = "https://github.com/Zeioth/heirline-components.nvim/";
    }).overrideAttrs
      {
        nvimRequireCheck = "heirline-components";
      };
in
{

  vim.visuals.nvim-web-devicons.enable = true;

  vim.extraPlugins = {
    heirline-components = {
      package = heirline-components-nvim;
    };

    heirline = {
      package = pkgs.vimPlugins.heirline-nvim;
      after = [
        "heirline-components"
        "gitsigns"
      ];
      setup =
        # lua
        ''
          lib = require("heirline-components.all")

          local opts = {
            -- opts = {
            --   disable_winbar_cb = function(args) -- avoid showing winbar on the greeter
            --     local is_disabled = not require("heirline-components.buffer").is_valid(args.buf) or
            --         lib.condition.buffer_matches({
            --           buftype = { "terminal", "prompt", "nofile", "help", "quickfix" },
            --           filetype = {
            --             "neo-tree",
            --             "dashboard",
            --           },
            --         }, args.buf)
            --     return is_disabled
            --   end,
            -- },
            tabline = { -- UI upper bar
              lib.component.tabline_conditional_padding(),
              lib.component.tabline_buffers(),
              lib.component.fill { hl = { bg = "tabline_bg" } },
              lib.component.tabline_tabpages(),
            },

            winbar = { -- UI breadcrumbs bar
              init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
              fallthrough = false,
              -- Winbar for terminal, neotree, and aerial.
              {
                condition = function() return not lib.condition.is_active() end,
                {
                  lib.component.neotree(),
                  lib.component.compiler_play(),
                  lib.component.fill(),
                  lib.component.compiler_redo(),
                  lib.component.aerial(),
                },
              },
              -- Regular winbar
              {
                lib.component.neotree(),
                lib.component.compiler_play(),
                lib.component.fill(),
                lib.component.breadcrumbs(),
                lib.component.fill(),
                lib.component.compiler_redo(),
                lib.component.aerial(),
              },
            },

            statuscolumn = { -- UI left column
              init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
              lib.component.foldcolumn(),
              lib.component.numbercolumn(),
              lib.component.signcolumn(),
            },

            statusline = { -- UI statusbar
              hl = { fg = "fg", bg = "bg" },
              lib.component.mode(),
              lib.component.git_branch(),
              lib.component.git_diff(),
              lib.component.file_info(),
              lib.component.diagnostics(),
              lib.component.fill(),
              lib.component.cmd_info(),
              lib.component.fill(),
              lib.component.lsp(),
              lib.component.compiler_state(),
              lib.component.virtual_env(),
              lib.component.nav(),
              lib.component.file_encoding(),
              lib.component.mode { surround = { separator = "right" } },
            },
          }

          local heirline = require("heirline")

          -- Setup
          lib.init.subscribe_to_events()
          heirline.load_colors(lib.hl.get_colors())
          heirline.setup(opts)
        '';
    };
  };
}
