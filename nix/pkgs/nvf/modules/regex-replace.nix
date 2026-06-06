{ pkgs, ... }:
{
  vim.lazy.plugins = {
    nvim-spectre = {
      lazy = true;

      package = pkgs.vimPlugins.nvim-spectre;

      keys = [
        {
          mode = "n";
          key = "<Leader>sw";
          action = /* lua */ ''
            function() require('spectre').open_visual({ select_word = true }) end
          '';
          lua = true;
          desc = "Search current word.";
        }
        {
          key = "<Leader>sS";
          mode = [ "v" ];

          action = /* lua */ ''
            function() require('spectre').open_visual() end
          '';
          lua = true;
          desc = "Search selection.";
        }
        {
          mode = "n";
          key = "<Leader>sp";
          action = /* lua */ ''
            function() require('spectre').open_file_search({ select_word = true }) end
          '';
          lua = true;
          desc = "Search current word in file.";
        }
        {
          mode = "n";
          key = "<Leader>sS";
          action = /* lua */ ''
            function() require('spectre').toggle() end
          '';
          lua = true;
          desc = "Search with Spectre";
        }
      ];
    };
  };
}
