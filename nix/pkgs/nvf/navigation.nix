{ ... }:
{
  vim.keymaps = [
    # Window movements.
    {
      key = "<C-h>";
      mode = [ "n" ];
      action = "<C-w>h";
      silent = true;
      desc = "Move to left window.";
    }
    {
      key = "<C-l>";
      mode = [ "n" ];
      action = "<C-w>l";
      silent = true;
      desc = "Move to right window.";
    }
    {
      key = "<C-j>";
      mode = [ "n" ];
      action = "<C-w>j";
      silent = true;
      desc = "Move to window below.";
    }
    {
      key = "<C-k>";
      mode = [ "n" ];
      action = "<C-w>k";
      silent = true;
      desc = "Move to window above.";
    }

    # Smart cursor line movements.
    {
      mode = "n";
      key = "j";
      action = "v:count == 0 ? 'gj' : 'j'";
      expr = true;
      silent = true;
      desc = "Move cursor down.";
    }
    {
      mode = "x";
      key = "j";
      action = "v:count == 0 ? 'gj' : 'j'";
      expr = true;
      silent = true;
      desc = "Move cursor down.";
    }
    {
      mode = "n";
      key = "k";
      action = "v:count == 0 ? 'gk' : 'k'";
      expr = true;
      silent = true;
      desc = "Move cursor up.";
    }
    {
      mode = "x";
      key = "k";
      action = "v:count == 0 ? 'gk' : 'k'";
      expr = true;
      silent = true;
      desc = "Move cursor up.";
    }
  ];
}
