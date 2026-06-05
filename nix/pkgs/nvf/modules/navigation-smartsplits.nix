{ ... }:
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
}
