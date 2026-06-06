{
  lib,
  config,
  pkgs,
  ...
}:
let
  icons = config.gabyx.icons;

  mkIconRules = patterns: conf: lib.map (p: conf // { pattern = p; }) patterns;

in
{
  # Better Escaping for certain key combinations.
  # Not really needed now.
  vim.extraPlugins = lib.mkIf false {
    "better-escape" = {
      package = pkgs.vimPlugins.better-escape-nvim;
      setup = # lua
        ''
          require("better-escape").setup({
          {
              timeout = 300,
              default_mappings = false,
              mappings = {
                i = { j = { k = "<Esc>", j = "<Esc>" } },
              },
            }
          })
        '';
    };
  };

  vim.mini.icons.enable = true; # which-key wants these.
  vim.binds.whichKey = {
    enable = true;
    register = lib.mkForce { };

    setupOpts = {
      preset = "modern";
      notify = true;
      icons = {
        group = "";
        rules =
          (mkIconRules
            [
              "%f[%a]git"
              "diffview"
              "lazygit"
            ]
            {
              cat = "filetype";
              name = "git";
            }
          )
          ++ [
            {
              icon = "󱡁";
              pattern = "harpoon";
            }
            {
              icon = icons.Navigation;
              pattern = "hop";
            }
            {
              icon = icons.DiagnosticError;
              pattern = "error";
            }
            {
              icon = icons.DiagnosticWarn;
              pattern = "warning";
            }
            {
              icon = icons.DiagnosticInfo;
              pattern = "info";
            }
            {
              icon = icons.Macro;
              pattern = "macro";
            }
            {
              pattern = "sort";
              icon = icons.Sort;
            }
            {
              pattern = "toggle";
              icon = icons.Toggle;
              color = "yellow";
            }
            {
              icon = icons.LineNumber;
              pattern = "line number";
            }
            {
              icon = icons.Indent;
              pattern = "indent";
            }
            {
              icon = icons.Bookmarks;
              pattern = "bookmark";
            }
            {
              icon = icons.Mark;
              pattern = "mark";
            }
            {
              icon = icons.Undo;
              pattern = "undo";
            }
            {
              icon = icons.Browse;
              pattern = "browse";
              color = "yellow";
            }
            {
              icon = icons.Status;
              pattern = "status";
            }
            {
              icon = icons.GitBranch;
              pattern = "branch";
            }
            {
              icon = icons.GitChange;
              pattern = "commit";
            }
            {
              icon = icons.GitBlame;
              pattern = "blame";
            }
            {
              icon = icons.GitDiff;
              pattern = "diff";
            }
            {
              icon = icons.Reset;
              pattern = "reset";
              color = "red";
            }
            {
              pattern = "stage.*unstage";
              icon = icons.GitStaged + icons.GitUnstaged;
            }
            {
              icon = icons.GitHunk;
              pattern = "hunk";
            }
            {
              pattern = "stage";
              icon = icons.GitStaged;
            }
            {
              pattern = "stash";
              icon = icons.GitStash;
            }
            {
              pattern = "[Uu][Ii].*";
              icon = "󰙵 ";
            }

            {
              pattern = "terminal";
              icon = " ";
            }
            {
              pattern = "find";
              icon = " ";
            }
            {
              pattern = "search";
              icon = " ";
            }
            {
              pattern = "file";
              icon = "󰈔 ";
            }
            {
              pattern = "window";
              icon = " ";
            }
            {
              pattern = "diagnostic";
              icon = "󱖫 ";
            }
            {
              pattern = "format";
              icon = " ";
            }
            {
              pattern = "debug";
              icon = "󰃤 ";
            }
            {
              pattern = "code";
              icon = " ";
            }
            {
              pattern = "notif";
              icon = "󰵅 ";
            }
            {
              pattern = "session";
              icon = "";
            }
            {
              pattern = "close";
              icon = icons.BufferClose;
            }
            {
              pattern = "exit";
              icon = "󰈆 ";
            }
            {
              pattern = "quit";
              icon = "󰈆 ";
            }
            {
              pattern = "buffer";
              icon = icons.DefaultFile;
            }
            {
              pattern = "tab";
              icon = "󰓩 ";
            }
            {
              pattern = "%f[%a]ai";
              icon = " ";
            }
          ]
          ++ (mkIconRules [ "list" "log" ] { icon = icons.List; })
          ++ [
            {
              plugin = "neo-tree.nvim";
              cat = "filetype";
              name = "neo-tree";
            }
            {
              plugin = "nvim-spectre";
              icon = "󰛔 ";
            }
            # Fallback to set no icon.
            {
              pattern = ".*";
              icon = "";
            }
          ];
      };
    };
  };

  vim.pluginRC.whichkey-extra =
    lib.nvim.dag.entryAfter [ "whichkey" ]
      # Lua
      ''
        local wk = require("which-key")
        wk.add({
          { "<Leader>f", icon = "${icons.Search}", desc = "Find ${icons.Ellipsis}" },
          { "<Leader>l", icon = "${icons.ActiveLSP}", desc = "Language Tools ${icons.Ellipsis}" },
          { "<Leader>u", icon = "${icons.Window}", desc = "UI/UX ${icons.Ellipsis}" },
          { "<Leader>b", icon = "${icons.Tab}", desc = "Buffers ${icons.Ellipsis}" },
          { "<Leader>bs",icon = "${icons.Sort}", desc = "Sort Buffers ${icons.Ellipsis}" },
          { "<Leader>bm",icon = "${icons.Move}", desc = "Move Buffers ${icons.Ellipsis}" },
          { "<Leader>d", icon = "${icons.Debugger}", desc = "Debugger ${icons.Ellipsis}" },
          { "<Leader>g", icon = "${icons.Git}",  desc = "Git ${icons.Ellipsis}" },
          { "<Leader>s", icon = "${icons.Search}", desc = "Search ${icons.Ellipsis}" },
          { "<Leader>S", icon = "${icons.Session}", desc = "Session ${icons.Ellipsis}" },
          { "<Leader>t", icon = "${icons.Terminal}", desc = "Terminal ${icons.Ellipsis}" },
          { "<Leader>m", icon = "${icons.Mark}", desc = "Marks ${icons.Ellipsis}" },
          { "<Leader>x", icon = "${icons.List}", desc = "Trouble ${icons.Ellipsis}" },
          { "<Leader>j", icon = "${icons.Navigation}", desc = "Navigation ${icons.Ellipsis}" },
        })
      '';

  vim.keymaps = [
    # Exiting.
    {
      mode = "n";
      key = "<C-Q>";
      action = "<Cmd>q!<CR>";
      desc = "Force quit.";
    }
    {
      mode = "n";
      key = "<Leader>q";
      action = "<Cmd>confirm q<CR>";
      desc = "Quit window.";
    }
    {
      mode = "n";
      key = "<Leader>Q";
      action = "<Cmd>confirm qall<CR>";
      desc = "Exit.";
    }

    # Saving.
    {
      mode = "n";
      key = "<Leader>w";
      action = "<Cmd>w<CR>";
      desc = "Save file.";
    }
    {
      mode = "n";
      key = "<C-S>";
      action = "<Cmd>silent! update! | redraw<CR>";
      desc = "Force write.";
    }

    # Split.
    {
      mode = "n";
      key = "|";
      action = "<Cmd>vsplit<CR>";
      desc = "Vertical split.";
    }
    {
      mode = "n";
      key = "\\";
      action = "<Cmd>split<CR>";
      desc = "Horizontal split.";
    }

    # Comment.
    {
      mode = "n";
      key = "<Leader>/";
      action = "gcc";
      noremap = false;
      desc = "Toggle comment line.";
    }
    {
      mode = "x";
      key = "<Leader>/";
      action = "gc";
      noremap = false;
      desc = "Toggle comment.";
    }

    # New File.
    {
      mode = "n";
      key = "<Leader>n";
      action = "<Cmd>enew<CR>";
      desc = "New file.";
    }

    # Buffer Commands.
    {
      mode = "n";
      key = "<Leader>c";
      action = /* Lua */ ''
        function() require("gabyx.buffer").close() end
      '';
      lua = true;
      desc = "Close buffer.";
    }
    {
      mode = "n";
      key = "<Leader>C";
      action = /* Lua */ ''
        function() require("gabyx.buffer").close(0, true) end
      '';
      lua = true;
      desc = "Close buffer forced.";
    }
    {
      mode = "n";
      key = "]b";
      action = /* Lua */ ''
        function() require("gabyx.buffer").nav(vim.v.count1) end
      '';
      lua = true;
      desc = "Next buffer.";
    }
    {
      mode = "n";
      key = "[b";
      action = /* Lua */ ''
        function() require("gabyx.buffer").nav(-vim.v.count1) end
      '';
      lua = true;
      desc = "Previous buffer.";
    }
    {
      mode = "n";
      key = ">b";
      action = /* Lua */ ''
        function() require("gabyx.buffer").move(vim.v.count1) end
      '';
      lua = true;
      desc = "Move buffer tab right.";
    }
    {
      mode = "n";
      key = "<b";
      action = /* Lua */ ''
        function() require("gabyx.buffer").move(-vim.v.count1) end
      '';
      lua = true;
      desc = "Move buffer tab left.";
    }

    # TODO: Translate this.
    # return {
    #
    #     -- initialize mappings table
    #     local maps = astro.empty_map_table()
    #     local sections = assert(opts._map_sections)
    #
    #     -- Normal --
    #     -- Standard Operations DONE
    #
    #     maps.n["<Leader>b"] = vim.tbl_get(sections, "b")
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
    #
    #
    #     -- Split navigation
    #     maps.n["<C-H>"] = { "<C-w>h", desc = "Move to left split" }
    #     maps.n["<C-J>"] = { "<C-w>j", desc = "Move to below split" }
    #     maps.n["<C-K>"] = { "<C-w>k", desc = "Move to above split" }
    #     maps.n["<C-L>"] = { "<C-w>l", desc = "Move to right split" }
    #     maps.n["<C-Up>"] = { "<Cmd>resize -2<CR>", desc = "Resize split up" }
    #     maps.n["<C-Down>"] = { "<Cmd>resize +2<CR>", desc = "Resize split down" }
    #     maps.n["<C-Left>"] = { "<Cmd>vertical resize -2<CR>", desc = "Resize split left" }
    #     maps.n["<C-Right>"] = { "<Cmd>vertical resize +2<CR>", desc = "Resize split right" }
    #
    #     -- List management
    #     maps.n["<Leader>x"] = vim.tbl_get(sections, "x")
    #     maps.n["<Leader>xq"] = { "<Cmd>copen<CR>", desc = "Quickfix List" }
    #     maps.n["<Leader>xl"] = { "<Cmd>lopen<CR>", desc = "Location List" }
    #     if vim.fn.has "nvim-0.11" == 0 then
    #       maps.n["]q"] = { vim.cmd.cnext, desc = "Next quickfix" }
    #       maps.n["[q"] = { vim.cmd.cprev, desc = "Previous quickfix" }
    #       maps.n["]Q"] = { vim.cmd.clast, desc = "End quickfix" }
    #       maps.n["[Q"] = { vim.cmd.cfirst, desc = "Beginning quickfix" }
    #
    #       maps.n["]l"] = { vim.cmd.lnext, desc = "Next loclist" }
    #       maps.n["[l"] = { vim.cmd.lprev, desc = "Previous loclist" }
    #       maps.n["]L"] = { vim.cmd.llast, desc = "End loclist" }
    #       maps.n["[L"] = { vim.cmd.lfirst, desc = "Beginning loclist" }
    #     end
  ];
}
