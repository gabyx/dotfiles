{ ... }:
{
  vim.keymaps = [
    {
      key = "<C-h>";
      mode = [ "n" ];
      action = "<C-w>h";
      silent = true;
      desc = "Move to left window";
    }
    {
      key = "<C-l>";
      mode = [ "n" ];
      action = "<C-w>l";
      silent = true;
      desc = "Move to right window";
    }
    {
      key = "<C-j>";
      mode = [ "n" ];
      action = "<C-w>j";
      silent = true;
      desc = "Move to window below";
    }
    {
      key = "<C-k>";
      mode = [ "n" ];
      action = "<C-w>k";
      silent = true;
      desc = "Move to window above";
    }
  ];
}
