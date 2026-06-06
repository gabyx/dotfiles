{ lib, ... }:
let
  inherit (lib.nvim.binds) pushDownDefault;
in
{
  vim.utility.smart-splits = {
    enable = true;

    keymaps = {
      move_cursor_up = "<C-K>";
      move_cursor_down = "<C-J>";
      move_cursor_left = "<C-H>";
      move_cursor_right = "<C-L>";

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
        "nofile"
        "quickfix"
        "qf"
        "prompt"
      ];
      ignored_buftypes = [ "nofile" ];
    };
  };

  vim.keymaps = [
    {
      mode = "n";
      key = "<Leader>bmh";
      action = /* Lua */ ''
        function() require("smart-splits").swap_buf_left() end
      '';
      desc = "Swap buffer left.";
    }
    {
      mode = "n";
      key = "<Leader>bml";
      action = /* Lua */ ''
        function() require("smart-splits").swap_buf_right() end
      '';
      desc = "Swap buffer right.";
    }
    {
      mode = "n";
      key = "<Leader>bmk";
      action = /* Lua */ ''
        function() require("smart-splits").swap_buf_up() end
      '';
      desc = "Swap buffer up.";
    }
    {
      mode = "n";
      key = "<Leader>bmj";
      action = /* Lua */ ''
        function() require("smart-splits").swap_buf_down() end
      '';
      desc = "Swap buffer down.";
    }
  ];

  vim.binds.whichKey.register = pushDownDefault {
    "<Leader>bm" = "Move/swap buffers.";
  };
}
