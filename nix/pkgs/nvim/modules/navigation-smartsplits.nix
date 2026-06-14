{ lib, ... }:
let
  inherit (lib.nvim.binds) pushDownDefault;
in
{
  vim.utility.smart-splits = {
    enable = true;

    keymaps = {
      move_cursor_up = "<C-k>";
      move_cursor_down = "<C-j>";
      move_cursor_left = "<C-h>";
      move_cursor_right = "<C-l>";

      resize_up = "<C-Up>";
      resize_down = "<C-Down>";
      resize_left = "<C-Left>";
      resize_right = "<C-Right>";

      swap_buf_left = "<Leader>bmh";
      swap_buf_right = "<Leader>bml";
      swap_buf_up = "<Leader>bmk";
      swap_buf_down = "<Leader>bmj";
    };

    setupOpts = {
      ignored_filetypes = [
        "neo-tree"
        "undotree"
      ];
      ignored_buftypes = [
        "nofile"
        "quickfix"
        "prompt"
      ];
      log_level = "info";
    };
  };

  vim.keymaps = [
    {
      mode = "n";
      key = "<Leader>bmh";
      action = /* lua */ ''
        function() require("smart-splits").swap_buf_left() end
      '';
      desc = "Swap buffer left.";
    }
    {
      mode = "n";
      key = "<Leader>bml";
      action = /* lua */ ''
        function() require("smart-splits").swap_buf_right() end
      '';
      desc = "Swap buffer right.";
    }
    {
      mode = "n";
      key = "<Leader>bmk";
      action = /* lua */ ''
        function() require("smart-splits").swap_buf_up() end
      '';
      desc = "Swap buffer up.";
    }
    {
      mode = "n";
      key = "<Leader>bmj";
      action = /* lua */ ''
        function() require("smart-splits").swap_buf_down() end
      '';
      desc = "Swap buffer down.";
    }
  ];

  vim.binds.whichKey.register = pushDownDefault {
    "<Leader>bm" = "Move/swap buffers.";
  };
}
