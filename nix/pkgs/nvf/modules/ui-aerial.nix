{ pkgs, ... }:
{
  vim.extraPlugins = {
    aerial = {
      package = pkgs.vimPlugins.aerial-nvim;
      setup =
        # Lua
        ''
          opts = {
            attach_mode = "global",
            backends = { "lsp", "treesitter", "markdown", "man" },
            layout = { min_width = 28 },
            show_guides = true,
            filter_kind = false,

            guides = {
              mid_item = "├ ",
              last_item = "└ ",
              nested_top = "│ ",
              whitespace = "  ",
            },

            keymaps = {
              ["[k"] = "actions.prev",
              ["[j"] = "actions.next",
              ["[h"] = "actions.prev_up",
              ["[l"] = "actions.next_up",
              ["{"] = false,
              ["}"] = false,
              ["[["] = false,
              ["]]"] = false,
            },

            on_attach = function(bufnr)
              local aerial = require("aerial")
              local function map(lhs, rhs, desc)
                vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
              end
              map("[k", function() aerial.prev(vim.v.count1) end, "Previous symbol.")
              map("[l", function() aerial.next(vim.v.count1) end, "Next symbol.")
              map("[h", function() aerial.prev_up(vim.v.count1) end, "Previous symbol upwards.")
              map("[l", function() aerial.next_up(vim.v.count1) end, "Next symbol upwards.")
            end,
          }

          require("aerial").setup(opts)
        '';
    };
  };

  vim.keymaps = [
    {
      key = "<Leader>lS";
      mode = [ "n" ];
      action = /* Lua */ ''function() require("aerial").toggle() end'';
      lua = true;
      desc = "Symbols outline.";
    }
  ];
}
