{ config, lib, ... }:
let
  icons = config.gabyx.icons;
in
{
  vim.utility.snacks-nvim = {
    enable = true;
    setupOpts = {
      input.enabled = true;
      notifier.enabled = true;
      picker.ui_select = true;

      image = {
        doc = {
          enabled = false;
        };
      };

      # Indent guides.
      indent = {
        enabled = true;
        indent.char = "▏";
        scope.char = "▏";
        animate.enabled = false;
        filter =
          lib.mkLuaInline
            # Lua
            ''
              function(bufnr)
                buffer = require("gabyx.buffer")
                return buffer.is_valid(bufnr)
                  and not buffer.is_large(bufnr)
                  and vim.g.snacks_indent ~= false
                  and vim.b[bufnr].snacks_indent ~= false
              end
            '';
      };

      # Scope detection.
      scope = {
        enabled = true;
        filter =
          lib.mkLuaInline
            # Lua
            ''
              function(bufnr)
                buffer = require("gabyx.buffer")
                return buffer.is_valid(bufnr)
                  and not buffer.is_large(bufnr)
                  and vim.g.snacks_scope ~= false
                  and vim.b[bufnr].snacks_scope ~= false
              end
            '';
      };

      # Word highlights.
      words = {
        enabled = true;
        filter =
          lib.mkLuaInline
            # Lua
            ''
              function(bufnr)
                buffer = require("gabyx.buffer")
                return buffer.is_valid(bufnr)
                  and not buffer.is_large(bufnr)
                  and vim.g.snacks_words ~= false
                  and vim.b[bufnr].snacks_words ~= false
              end
            '';
      };

      # Zen mode.
      zen = {
        enabled = true;

        toggles = {
          dim = false;
          diagnostics = false;
          inlay_hints = false;
        };

        on_open =
          lib.mkLuaInline
            # Lua
            ''
              function(win)
                vim.b[win.buf].snacks_indent_old = vim.b[win.buf].snacks_indent
                vim.b[win.buf].snacks_indent = false
              end
            '';

        on_close =
          lib.mkLuaInline
            # Lua
            ''
              function(win)
                vim.b[win.buf].snacks_indent = vim.b[win.buf].snacks_indent_old
              end
            '';

        win = {
          width =
            lib.mkLuaInline
              # Lua
              ''
                function() return math.min(120, math.floor(vim.o.columns * 0.75)) end
              '';
          height = 0.9;
          backdrop = {
            transparent = false;
            win.wo.winhighlight = "Normal:Normal";
          };
          wo = {
            number = false;
            relativenumber = false;
            signcolumn = "no";
            foldcolumn = "0";
            winbar = "";
            list = false;
            showbreak = "NONE";
          };
        };
      };

      dashboard = {
        enable = true;
        preset = {
          keys = [
            {
              key = "n";
              action = "<Leader>n";
              icon = icons.FileNew;
              desc = "New File.";
            }
            {
              key = "f";
              action = "<Leader>ff";
              icon = icons.Search;
              desc = "Find File.";
            }
            {
              key = "o";
              action = "<Leader>fo";
              icon = icons.DefaultFile;
              desc = "Recents.";
            }
            {
              key = "w";
              action = "<Leader>fw";
              icon = icons.WordFile;
              desc = "Find Word.";
            }
            {
              key = "'";
              action = "<Leader>f'";
              icon = icons.Bookmarks;
              desc = "Bookmarks.";
            }
            {
              key = "s";
              action = "<Leader>Sl";
              icon = icons.Refresh;
              desc = "Last Session.";
            }
          ];

          header = ''
            Gabyx's Nvim Config
          '';
        };

        sections = [
          {
            section = "header";
            padding = 5;
          }
          {
            section = "keys";
            gap = 1;
            padding = 3;
          }
          # { section = "startup"; }
        ];
      };
    };
  };

  # Snack related keymaps.
  vim.keymaps = [
    # Notifier.
    {
      key = "<Leader>uD";
      mode = [ "n" ];
      action = /* Lua */ "function() require('snacks.notifier').hide() end";
      silent = true;
      desc = "Dismiss notifications.";
    }

    # Indent toggle.
    {
      key = "<Leader>u|";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').toggle.indent():toggle() end
      '';
      lua = true;
      silent = true;
      desc = "Toggle indent guides.";
    }

    # Words.
    {
      key = "<Leader>ur";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').toggle.words():toggle() end
      '';
      lua = true;
      silent = true;
      desc = "Toggle reference highlighting.";
    }
    {
      key = "]r";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').words.jump(vim.v.count1) end
      '';
      lua = true;
      silent = true;
      desc = "Next reference.";
    }
    {
      key = "[r";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').words.jump(-vim.v.count1) end
      '';
      lua = true;
      silent = true;
      desc = "Previous reference.";
    }
    # Zen.
    {
      key = "<Leader>uZ";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').toggle.zen():toggle() end
      '';
      lua = true;
      silent = true;
      desc = "Toggle zen mode.";
    }

    # Picker.
    {
      key = "<Leader>f<CR>";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.resume() end
      '';
      lua = true;
      silent = true;
      desc = "Resume previous search.";
    }
    {
      key = "<Leader>f'";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.marks() end
      '';
      lua = true;
      silent = true;
      desc = "Find marks.";
    }
    {
      key = "<Leader>fb";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.buffers() end
      '';
      lua = true;
      silent = true;
      desc = "Find buffers.";
    }
    {
      key = "<Leader>fc";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.grep_word() end
      '';
      lua = true;
      silent = true;
      desc = "Find word under cursor.";
    }
    {
      key = "<Leader>fC";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.commands() end
      '';
      lua = true;
      silent = true;
      desc = "Find commands.";
    }
    {
      key = "<Leader>ff";
      mode = [ "n" ];
      action = /* Lua */ ''
        function()
          require('snacks').picker.files {
            hidden = vim.uv.fs_stat(".git") ~= nil,
          }
        end
      '';
      lua = true;
      silent = true;
      desc = "Find files.";
    }
    {
      key = "<Leader>fF";
      mode = [ "n" ];
      action = /* Lua */ ''
        function()
          require('snacks').picker.files { hidden = true, ignored = true }
        end
      '';
      lua = true;
      silent = true;
      desc = "Find all files.";
    }
    {
      key = "<Leader>fh";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.help() end
      '';
      lua = true;
      silent = true;
      desc = "Find help.";
    }
    {
      key = "<Leader>fk";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.keymaps() end
      '';
      lua = true;
      silent = true;
      desc = "Find keymaps.";
    }
    {
      key = "<Leader>fm";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.man() end
      '';
      lua = true;
      silent = true;
      desc = "Find man pages.";
    }
    {
      key = "<Leader>fn";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.notifications() end
      '';
      lua = true;
      silent = true;
      desc = "Find notifications.";
    }
    {
      key = "<Leader>fo";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.recent() end
      '';
      lua = true;
      silent = true;
      desc = "Find recent files.";
    }
    {
      key = "<Leader>fO";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.recent { filter = { cwd = true } } end
      '';
      lua = true;
      silent = true;
      desc = "Find recent files (cwd).";
    }
    {
      key = "<Leader>fp";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.projects() end
      '';
      lua = true;
      silent = true;
      desc = "Find projects.";
    }
    {
      key = "<Leader>fr";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.registers() end
      '';
      lua = true;
      silent = true;
      desc = "Find registers.";
    }
    {
      key = "<Leader>fs";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.smart() end
      '';
      lua = true;
      silent = true;
      desc = "Find buffers/recent/files.";
    }
    {
      key = "<Leader>ft";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.colorschemes() end
      '';
      lua = true;
      silent = true;
      desc = "Find themes.";
    }
    {
      key = "<Leader>fw";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.grep() end
      '';
      lua = true;
      silent = true;
      desc = "Find words.";
    }
    {
      key = "<Leader>fW";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.grep { hidden = true, ignored = true } end
      '';
      lua = true;
      silent = true;
      desc = "Find words in all files.";
    }
    {
      key = "<Leader>fu";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.undo() end
      '';
      lua = true;
      silent = true;
      desc = "Find undo history.";
    }
    {
      key = "<Leader>fl";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.lines() end
      '';
      lua = true;
      silent = true;
      desc = "Find lines.";
    }
    {
      key = "<Leader>lD";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.diagnostics() end
      '';
      lua = true;
      silent = true;
      desc = "Search diagnostics.";
    }
    {
      key = "<Leader>ls";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.lsp_symbols() end
      '';
      lua = true;
      silent = true;
      desc = "Search symbols.";
    }

    # Git picker mappings.
    {
      key = "<Leader>gb";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.git_branches() end
      '';
      lua = true;
      silent = true;
      desc = "Branches.";
    }
    {
      key = "<Leader>gc";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.git_log() end
      '';
      lua = true;
      silent = true;
      desc = "Commits (repository).";
    }
    {
      key = "<Leader>gC";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.git_log { current_file = true, follow = true } end
      '';
      lua = true;
      silent = true;
      desc = "Commits (current file).";
    }
    {
      key = "<Leader>gt";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.git_status() end
      '';
      lua = true;
      silent = true;
      desc = "Status.";
    }
    {
      key = "<Leader>gT";
      mode = [ "n" ];
      action = /* Lua */ ''
        function() require('snacks').picker.git_stash() end
      '';
      lua = true;
      silent = true;
      desc = "Stash.";
    }
    {
      key = "<Leader>go";
      mode = [
        "n"
        "x"
      ];
      action = /* Lua */ ''
        function() require('snacks').gitbrowse() end
      '';
      lua = true;
      silent = true;
      desc = "Browse remotes.";
    }
  ];

  # Snacks filetree functions.
  vim.filetree.neo-tree.setupOpts = {
    commands = {
      find_files_in_dir =
        lib.mkLuaInline
          # Lua
          ''
            function(state)
              local node = state.tree:get_node()
              local path = node.type == "file" and node:get_parent_id() or node:get_id()
              require("snacks").picker.files { cwd = path }
            end
          '';

      find_all_files_in_dir =
        lib.mkLuaInline
          # Lua
          ''
            function(state)
              local node = state.tree:get_node()
              local path = node.type == "file" and node:get_parent_id() or node:get_id()
              require("snacks").picker.files { cwd = path, hidden = true, ignored = true }
            end
          '';
      find_words_in_dir =
        lib.mkLuaInline
          # Lua
          ''
            function(state)
              local node = state.tree:get_node()
              local path = node.type == "file" and node:get_parent_id() or node:get_id()
              require("snacks").picker.grep { cwd = path }
            end
          '';
      find_all_words_in_dir =
        lib.mkLuaInline
          # Lua
          ''
            function(state)
              local node = state.tree:get_node()
              local path = node.type == "file" and node:get_parent_id() or node:get_id()
              require("snacks").picker.grep { cwd = path, hidden = true, ignored = true }
            end
          '';
    };
    filesystem = {
      window = {
        mappings = {
          "f" = {
            command = "show_help";
            nowait = false;
            config = {
              title = "Find Files";
              prefix_key = "f";
            };
          };
          "f/" = "filter_on_submit";
          "ff" = "find_files_in_dir";
          "fF" = "find_all_files_in_dir";
          "fw" = "find_words_in_dir";
          "fW" = "find_all_words_in_dir";
        };
      };
    };
  };
}
