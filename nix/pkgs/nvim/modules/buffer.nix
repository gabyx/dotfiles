{ ... }:
{
  # TODO add all buffer mappings.
  vim.keymaps = [
    {
      mode = "n";
      key = "<Leader>c";
      action = /* lua */ ''
        function() require("gabyx.buffer").close() end
      '';
      lua = true;
      desc = "Close buffer.";
    }
    {
      mode = "n";
      key = "<Leader>C";
      action = /* lua */ ''
        function() require("gabyx.buffer").close(0, true) end
      '';
      lua = true;
      desc = "Close buffer forced.";
    }
    {
      mode = "n";
      key = "]b";
      action = /* lua */ ''
        function() require("gabyx.buffer").nav(vim.v.count1) end
      '';
      lua = true;
      desc = "Next buffer.";
    }
    {
      mode = "n";
      key = "[b";
      action = /* lua */ ''
        function() require("gabyx.buffer").nav(-vim.v.count1) end
      '';
      lua = true;
      desc = "Previous buffer.";
    }
    {
      mode = "n";
      key = ">b";
      action = /* lua */ ''
        function() require("gabyx.buffer").move(vim.v.count1) end
      '';
      lua = true;
      desc = "Move buffer tab right.";
    }
    {
      mode = "n";
      key = "<b";
      action = /* lua */ ''
        function() require("gabyx.buffer").move(-vim.v.count1) end
      '';
      lua = true;
      desc = "Move buffer tab left.";
    }
    {
      mode = "n";
      key = "<Leader>b.";
      lua = true;

      action = /* lua */ ''
        function()
          local path = vim.fn.expand("%:p")
          vim.fn.setreg('+', path)                 -- copy to system clipboard

          vim.notify(path, vim.log.levels.INFO, {
            title = "Buffer path (copied)",
            timeout = 5000,                         -- stays 5s so you can read it
            on_open = function(win)                 -- nvim-notify: widen + wrap to fit
              local width = math.min(#path + 4, vim.o.columns - 4)
              pcall(vim.api.nvim_win_set_width, win, width)
              vim.wo[win].wrap = true
            end,
          })
        end
      '';
      desc = "Show buffer path.";
    }
  ];

  # TODO
  #     maps.n["<Leader>bc"] =
  #       { function() require("astrocore.buffer").close_all(true) end, desc = "Close all buffers except current" }
  #     maps.n["<Leader>bC"] = { function() require("astrocore.buffer").close_all() end, desc = "Close all buffers" }
  #     maps.n["<Leader>bl"] =
  #       { function() require("astrocore.buffer").close_left() end, desc = "Close all buffers to the left" }
  #     maps.n["<Leader>bp"] = { function() require("astrocore.buffer").prev() end, desc = "Previous buffer" }
  #     maps.n["<Leader>br"] =
  #       { function() require("astrocore.buffer").close_right() end, desc = "Close all buffers to the right" }
  #     maps.n["<Leader>bs"] = vim.tbl_get(sections, "bs")
  #     maps.n["<Leader>bse"] = { function() require("astrocore.buffer").sort "extension" end, desc = "By extension" }
  #     maps.n["<Leader>bsr"] = { function() require("astrocore.buffer").sort "unique_path" end, desc = "By relative path" }
  #     maps.n["<Leader>bsp"] = { function() require("astrocore.buffer").sort "full_path" end, desc = "By full path" }
  #     maps.n["<Leader>bsi"] = { function() require("astrocore.buffer").sort "bufnr" end, desc = "By buffer number" }
  #     maps.n["<Leader>bsm"] = { function() require("astrocore.buffer").sort "modified" end, desc = "By modification" }
}
