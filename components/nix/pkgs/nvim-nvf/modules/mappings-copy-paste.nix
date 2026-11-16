{
  ...
}:
{
  # No clipboard override when pressing c, x or Del.
  vim.keymaps = [
    # Normal
    {
      key = "s";
      mode = "n";
      action = "\"_s";
      noremap = true;
    }
    {
      key = "S";
      mode = "n";
      action = "\"_S";
      noremap = true;
    }
    {
      key = "x";
      mode = "n";
      action = "\"_x";
      noremap = true;
    }
    {
      key = "X";
      mode = "n";
      action = "\"_x";
      noremap = true;
    }
    {
      key = "c";
      mode = "n";
      action = "\"_c";
      noremap = true;
    }
    {
      key = "C";
      mode = "n";
      action = "\"_c";
      noremap = true;
    }
    {
      key = "<Del>";
      mode = "n";
      action = "\"_x";
      noremap = true;
    }

    # Visual

    {
      key = "s";
      mode = "v";
      action = "\"_s";
      noremap = true;
    }
    {
      key = "S";
      mode = "v";
      action = "\"_S";
      noremap = true;
    }
    {
      key = "c";
      mode = "v";
      action = "\"_c";
      noremap = true;
    }
    {
      key = "C";
      mode = "v";
      action = "\"_c";
      noremap = true;
    }
    {
      key = "<Del>";
      mode = "v";
      action = "\"_x";
      noremap = true;
    }

    # No clipboard overwrite (reselect and yank again)
    # when pasting in visual mode.
    {
      key = "p";
      mode = "v";
      action = "pgvy";
      noremap = true;
    }
  ];
}
