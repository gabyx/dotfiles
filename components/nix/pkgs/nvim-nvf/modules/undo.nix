{ ... }:
{
  vim.utility.undotree.enable = true;

  vim.keymaps = [
    # Undotree
    {
      mode = "n";
      key = "<Leader>bu";
      action = /* lua */ "function() vim.cmd.UndotreeToggle() end";
      lua = true;
      desc = "Show Undo Tree.";
    }
  ];
}
