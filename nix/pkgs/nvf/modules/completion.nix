{ lib, ... }:
{
  vim.autopairs.nvim-autopairs.enable = true;

  # Recipes: https://main.cmp.saghen.dev/recipes.html
  vim.autocomplete.blink-cmp = {
    enable = true;

    sourcePlugins.emoji.enable = true;
    sourcePlugins.ripgrep.enable = true;
    sourcePlugins.spell.enable = true;
    friendly-snippets.enable = false;

    setupOpts = {
      fuzzy.implementation = "prefer_rust";

      snippets = {
        preset = "luasnip";
      };

      sources = {
        default = [
          "lsp"
          "snippets"
          "path"
          "buffer"
          "emoji"
          "ripgrep"
          "spell"
        ];
      };

      completion = {
        list = {
          preselect = true;
        };

        menu = {
          min_height = 40;

          auto_show = true;
          winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None";
          draw = {
            treesitter = [ "lsp" ];
            # components = {
            #   kind_icon = {
            #     # text = function(ctx) return get_kind_icon(ctx).text end,
            #     # highlight = function(ctx) return get_kind_icon(ctx).highlight end,
            #   };
            # };
          };
        };

        accept.auto_brackets.enabled = true;

        documentation = {
          auto_show = true;
          auto_show_delay_ms = 0;
          window.winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None";
        };
      };

      cmdline = {
        keymap."<End>" = [
          "hide"
          "fallback"
        ];
        completion.ghost_text.enabled = true;
      };

      signature.window.winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder";

      keymap = {
        preset = "none";
        "<C-Space>" = [
          "show"
          "show_documentation"
          "hide_documentation"
        ];
        "<Up>" = [
          "select_prev"
          "fallback"
        ];
        "<Down>" = [
          "select_next"
          "fallback"
        ];
        "<C-n>" = [
          "select_next"
          "show"
        ];
        "<C-p>" = [
          "select_prev"
          "show"
        ];
        "<C-j>" = [
          "select_next"
          "fallback"
        ];
        "<C-k>" = [
          "select_prev"
          "fallback"
        ];
        "<C-u>" = [
          "scroll_documentation_up"
          "fallback"
        ];
        "<C-d>" = [
          "scroll_documentation_down"
          "fallback"
        ];
        "<C-e>" = [
          "hide"
          "fallback"
        ];
        "<CR>" = [
          "accept"
          "fallback"
        ];

        "<Tab>" = [
          "select_next"
          "snippet_forward"
          (lib.generators.mkLuaInline
            # Lua
            ''
              function(cmp)
                local function has_words_before()
                  local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
                  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
                end

                if has_words_before() or vim.api.nvim_get_mode().mode == "c" then
                  return cmp.show()
                end
              end
            ''
          )
          "fallback"
        ];

        "<S-Tab>" = [
          "select_prev"
          "snippet_backward"
          (lib.generators.mkLuaInline
            # Lua
            ''
              function(cmp)
                if vim.api.nvim_get_mode().mode == "c" then return cmp.show() end
              end
            ''
          )
          "fallback"
        ];
      };
    };
  };
}
