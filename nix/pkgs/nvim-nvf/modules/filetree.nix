{ config, lib, ... }:
let
  icons = config.gabyx.icons;

  neo-tree = {
    enable = true;

    setupOpts = {
      enable_diagnostics = true;
      enable_git_status = true;
      enable_modified_markers = true;
      enable_opened_markers = true;
      enable_cursor_hijack = true;

      git_status_async = true;

      popup_border_style = "rounded";
      use_default_mappings = true;

      filesystem = {
        hijack_netrw_behavior = "open_current";

        follow_current_file = {
          enabled = true;
          leave_dirs_open = true;
        };

        filtered_items = {
          hide_dotfiles = false;
          hide_gitignored = false;

          hide_by_name = [
            ".git"
          ];

          never_show = [
            ".DS_Store"
          ];
        };

        group_empty_dirs = false;
        bind_to_cwd = true;
        use_libuv_file_watcher = true;
      };

      commands = {
        copy_selector = copySelector;
        parent_or_close = parentOrClose;
        child_or_open = childOrOpen;
      };

      window = {
        width = 30;
        position = "left";

        mappings = {
          "<CR>" = "open";
          "[b" = "prev_source";
          "]b" = "next_source";

          Y = "copy_selector";
          h = "parent_or_close";
          l = "child_or_open";
        };

        fuzzy_finder_mappings = {
          "<C-J>" = "move_cursor_down";
          "<C-K>" = "move_cursor_up";
        };
      };

      default_component_configs = {
        indent = {
          padding = 0;
          expander_collapsed = icons.FoldClosed;
          expander_expanded = icons.FoldOpened;
        };
        icon = {
          folder_closed = icons.FolderClosed;
          folder_open = icons.FolderOpen;
          folder_empty = icons.FolderEmpty;
          folder_empty_open = icons.FolderEmpty;
          default = icons.DefaultFile;
        };
        modified = {
          symbol = icons.FileModified;
        };
        git_status = {
          symbols = {
            added = icons.GitAdd;
            deleted = icons.GitDelete;
            modified = icons.GitChange;
            renamed = icons.GitRenamed;
            untracked = icons.GitUntracked;
            ignored = icons.GitIgnored;
            unstaged = icons.GitUnstaged;
            staged = icons.GitStaged;
            conflict = icons.GitConflict;
          };
        };
      };
    };
  };

  # Taken from: https://github.com/AstroNvim/AstroNvim/blob/a5c6434fae7fe60dbeb95158d26aa9b2d244c6c7/lua/astronvim/plugins/neo-tree.lua#L111
  parentOrClose =
    lib.mkLuaInline
      # Lua
      ''
        function(state)
          local node = state.tree:get_node()
          if node:has_children() and node:is_expanded() then
            state.commands.toggle_node(state)
          else
            require("neo-tree.ui.renderer").focus_node(
              state, node:get_parent_id())
          end
        end,
      '';

  # Taken from: https://github.com/AstroNvim/AstroNvim/blob/a5c6434fae7fe60dbeb95158d26aa9b2d244c6c7/lua/astronvim/plugins/neo-tree.lua#L119
  childOrOpen =
    lib.mkLuaInline
      # Lua
      ''
        function(state)
          local node = state.tree:get_node()
          if node:has_children() then
            if not node:is_expanded() then -- if unexpanded, expand
              state.commands.toggle_node(state)
            else -- if expanded and has children, seleect the next child
              if node.type == "file" then
                state.commands.open(state)
              else
                require("neo-tree.ui.renderer").focus_node(
                state, node:get_child_ids()[1])
              end
            end
          else -- if has no children
            state.commands.open(state)
          end
        end
      '';

  # Taken from: https://github.com/AstroNvim/AstroNvim/blob/a5c6434fae7fe60dbeb95158d26aa9b2d244c6c7/lua/astronvim/plugins/neo-tree.lua#L135
  copySelector =
    lib.mkLuaInline
      # Lua
      ''
        function(state)
          local node = state.tree:get_node()
          local filepath = node:get_id()
          local filename = node.name
          local modify = vim.fn.fnamemodify

          local vals = {
            ["BASENAME"] = modify(filename, ":r"),
            ["EXTENSION"] = modify(filename, ":e"),
            ["FILENAME"] = filename,
            ["PATH (CWD)"] = modify(filepath, ":."),
            ["PATH (HOME)"] = modify(filepath, ":~"),
            ["PATH"] = filepath,
            ["URI"] = vim.uri_from_fname(filepath),
          }

          local options = vim.tbl_filter(
            function(val) return vals[val] ~= "" end,
            vim.tbl_keys(vals)
          )

          if vim.tbl_isempty(options) then
            vim.notify("No values to copy", vim.log.levels.WARN)
            return
          end

          table.sort(options)

          vim.ui.select(
            options,
            {
              prompt = "Choose to copy to clipboard:",
              format_item = function(item) return ("%s: %s"):format(item, vals[item]) end,
            },
            function(choice)
              local result = vals[choice]
              if result then
                vim.notify(("Copied: `%s`"):format(result))
                vim.fn.setreg("+", result)
              end
            end
          )
        end
      '';
in
{
  vim.filetree = { inherit neo-tree; };

  vim.keymaps = [
    {
      key = "<Leader>e";
      mode = [ "n" ];
      action = "<Cmd>Neotree toggle<CR>";
      silent = true;
      desc = "Toggle Explorer.";
    }
  ];
}
