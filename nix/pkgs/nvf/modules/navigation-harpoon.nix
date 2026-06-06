{ pkgs, ... }:
{
  vim.extraPlugins.harpoon = {
    package = pkgs.vimPlugins.harpoon;
  };

  vim.keymaps = [
    {
      key = "<Leader>jf";
      mode = [
        "n"
        "v"
      ];
      lua = true;
      action = /* Lua */ ''
        function() require("harpoon.ui").toggle_quick_menu() end
      '';
      desc = "Harpoon list.";
    }
    {
      key = "<Leader>jj";
      mode = [
        "n"
        "v"
      ];
      lua = true;
      action = /* Lua */ ''
        function() require("harpoon.mark").add_file() end
      '';
      desc = "Add to harpoon list.";
    }
    {
      key = "<S-h>";
      mode = [
        "n"
        "v"
      ];
      lua = true;
      action = /* Lua */ ''
        function() require("harpoon.ui").nav_next() end
      '';
      desc = "Next harpoon file.";
    }
    {
      key = "<S-l>";
      mode = [
        "n"
        "v"
      ];
      lua = true;
      action = /* Lua */ ''
        function() require("harpoon.ui").nav_prev() end
      '';
      desc = "Previous harpoon file.";
    }
  ];
}
