{ ... }:
{
  vim.utility.undotree.enable = true;

  vim.keymaps = [
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

    {
      mode = "n";
      key = "]t";
      action = /* lua */ ''
        function() vim.cmd.tabnext() end
      '';
      lua = true;
      desc = "Go to next tab.";
    }
    {
      mode = "n";
      key = "[t";
      action = /* lua */ ''
        function() vim.cmd.tabprevious() end
      '';
      desc = "Go to previous tab.";
      lua = true;
    }

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
