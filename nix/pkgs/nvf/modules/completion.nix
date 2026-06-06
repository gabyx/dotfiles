{ lib, ... }:
{
  vim.autopairs.nvim-autopairs.enable = true;

  vim.autocomplete.blink-cmp = {
    enable = true;

    setupOpts = {
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
        "<C-N>" = [
          "select_next"
          "show"
        ];
        "<C-P>" = [
          "select_prev"
          "show"
        ];
        "<C-J>" = [
          "select_next"
          "fallback"
        ];
        "<C-K>" = [
          "select_prev"
          "fallback"
        ];
        "<C-U>" = [
          "scroll_documentation_up"
          "fallback"
        ];
        "<C-D>" = [
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

      fuzzy.implementation = "prefer_rust";

      sourcePlugins.emoji.enable = true;
      sourcePlugins.ripgrep.enable = true;
      sourcePlugins.spell.enable = true;

      completion = {
        list.select_next = {
          preselect = true;
          auto_insert = true;
        };

        menu = {
          auto_show = true;
          # lib.generators.mkLuaInline
          #   #Lua
          #   ''
          #     function(ctx) return ctx.mode ~= "cmdline" end
          #   '';
          # winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None";
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
        # documentation = {
        #   auto_show = true;
        #   auto_show_delay_ms = 0;
        #   window.winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None";
        # };
      };

      # cmdline = {
      #   keymap."<End>" = [
      #     "hide"
      #     "fallback"
      #   ];
      #   completion.ghost_text.enabled = false;
      # };

      # signature.window.winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder";
    };
  };
}
