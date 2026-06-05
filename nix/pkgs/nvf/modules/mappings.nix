{
  lib,
  config,
  pkgs,
  ...
}:
let
  icons = config.gabyx.icons;
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

    setupOpts = {
      preset = "modern";
      notify = true;
      icons = {
        group = " ";
      };
    };
  };

  vim.pluginRC.whichkey-extra =
    lib.nvim.dag.entryAfter [ "whichkey" ]
      # Lua
      ''
        local wk = require("which-key")
        wk.add({
          { "<leader>f", icon = "${icons.Search}", desc = "Find ${icons.Ellipsis}" },
          { "<leader>l", icon = "${icons.ActiveLSP}", desc = "Language Tools ${icons.Ellipsis}" },
          { "<leader>u", icon = "${icons.Window}", desc = "UI/UX ${icons.Ellipsis}" },
          { "<leader>b", icon = "${icons.Tab}", desc = "Buffers ${icons.Ellipsis}" },
          { "<leader>bs",icon = "${icons.Sort}", desc = "Sort Buffers ${icons.Ellipsis}" },
          { "<leader>d", icon = "${icons.Debugger}", desc = "Debugger ${icons.Ellipsis}" },
          { "<leader>g", icon = "${icons.Git}",  desc = "Git ${icons.Ellipsis}" },
          { "<leader>S", icon = "${icons.Session}", desc = "Session ${icons.Ellipsis}" },
          { "<leader>t", icon = "${icons.Terminal}", desc = "Terminal ${icons.Ellipsis}" },
          { "<leader>x", icon = "${icons.List}", desc = "Quickfix/Lists ${icons.Ellipsis}" },
          { "<leader>j", icon = "${icons.Navigation}", desc = "Navigation ${icons.Ellipsis}" },
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
    #     maps.n["<Leader>l"] = vim.tbl_get(sections, "l")
    #     maps.n["<Leader>li"] = { function() vim.cmd.checkhealth "vim.lsp" end, desc = "Lsp Information" }
    #     maps.n["<Leader>ld"] = { function() vim.diagnostic.open_float() end, desc = "Hover diagnostics" }
    #     local function diagnostic_jump(dir, severity)
    #       local jump_opts = {}
    #       if type(severity) == "string" then jump_opts.severity = vim.diagnostic.severity[severity] end
    #       return function()
    #         jump_opts.count = dir and vim.v.count1 or -vim.v.count1
    #         vim.diagnostic.jump(jump_opts)
    #       end
    #     end
    #     maps.n["[e"] = { diagnostic_jump(false, "ERROR"), desc = "Previous error" }
    #     maps.n["]e"] = { diagnostic_jump(true, "ERROR"), desc = "Next error" }
    #     maps.n["[w"] = { diagnostic_jump(false, "WARN"), desc = "Previous warning" }
    #     maps.n["]w"] = { diagnostic_jump(true, "WARN"), desc = "Next warning" }
    #     maps.n["gl"] = { function() vim.diagnostic.open_float() end, desc = "Hover diagnostics" }
    #
    #     -- Navigate tabs
    #     maps.n["]t"] = { function() vim.cmd.tabnext() end, desc = "Next tab" }
    #     maps.n["[t"] = { function() vim.cmd.tabprevious() end, desc = "Previous tab" }
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
    #
    #     -- Stay in indent mode
    #     maps.v["<S-Tab>"] = { "<gv", desc = "Unindent line" }
    #     maps.v["<Tab>"] = { ">gv", desc = "Indent line" }
    #
    #     -- Improved Terminal Navigation
    #     local function term_nav(dir)
    #       return function()
    #         if vim.api.nvim_win_get_config(0).zindex then
    #           vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-" .. dir .. ">", true, false, true), "n", false)
    #         else
    #           vim.cmd.wincmd(dir)
    #         end
    #       end
    #     end
    #     maps.t["<C-H>"] = { term_nav "h", desc = "Terminal left window navigation" }
    #     maps.t["<C-J>"] = { term_nav "j", desc = "Terminal down window navigation" }
    #     maps.t["<C-K>"] = { term_nav "k", desc = "Terminal up window navigation" }
    #     maps.t["<C-L>"] = { term_nav "l", desc = "Terminal right window navigation" }
    #
    #     maps.n["<Leader>u"] = vim.tbl_get(sections, "u")
    #     -- Custom menu for modification of the user experience
    #     maps.n["<Leader>uA"] = { function() require("astrocore.toggles").autochdir() end, desc = "Toggle rooter autochdir" }
    #     maps.n["<Leader>ub"] = { function() require("astrocore.toggles").background() end, desc = "Toggle background" }
    #     maps.n["<Leader>ud"] = { function() require("astrocore.toggles").diagnostics() end, desc = "Toggle diagnostics" }
    #     maps.n["<Leader>ug"] = { function() require("astrocore.toggles").signcolumn() end, desc = "Toggle signcolumn" }
    #     maps.n["<Leader>u>"] = { function() require("astrocore.toggles").foldcolumn() end, desc = "Toggle foldcolumn" }
    #     maps.n["<Leader>ui"] = { function() require("astrocore.toggles").indent() end, desc = "Change indent setting" }
    #     maps.n["<Leader>ul"] = { function() require("astrocore.toggles").statusline() end, desc = "Toggle statusline" }
    #     maps.n["<Leader>un"] = { function() require("astrocore.toggles").number() end, desc = "Change line numbering" }
    #     maps.n["<Leader>uN"] =
    #       { function() require("astrocore.toggles").notifications() end, desc = "Toggle Notifications" }
    #     maps.n["<Leader>up"] = { function() require("astrocore.toggles").paste() end, desc = "Toggle paste mode" }
    #     maps.n["<Leader>us"] = { function() require("astrocore.toggles").spell() end, desc = "Toggle spellcheck" }
    #     maps.n["<Leader>uS"] = { function() require("astrocore.toggles").conceal() end, desc = "Toggle conceal" }
    #     maps.n["<Leader>ut"] = { function() require("astrocore.toggles").tabline() end, desc = "Toggle tabline" }
    #     maps.n["<Leader>uu"] = { function() require("astrocore.toggles").url_match() end, desc = "Toggle URL highlight" }
    #     maps.n["<Leader>uv"] = { function() require("astrocore.toggles").virtual_text() end, desc = "Toggle virtual text" }
    #     maps.n["<Leader>uV"] =
    #       { function() require("astrocore.toggles").virtual_lines() end, desc = "Toggle virtual lines" }
    #     maps.n["<Leader>uw"] = { function() require("astrocore.toggles").wrap() end, desc = "Toggle wrap" }
    #     maps.n["<Leader>uy"] =
    #       { function() require("astrocore.toggles").buffer_syntax() end, desc = "Toggle syntax highlight (buffer)" }
    #
    #     opts.mappings = maps
    #   end,
    # }
  ];
}
