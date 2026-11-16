{ config, pkgs, ... }:
let
  icons = config.gabyx.icons;
in
{
  vim.terminal.toggleterm = {
    enable = true;
    lazygit = {
      enable = true;

      package = pkgs.lazygit;

      mappings = {
        open = "<Leader>gg";
      };
    };
  };

  vim.extraPlugins = {
    gitsigns = {
      package = pkgs.vimPlugins.gitsigns-nvim;
      setup =
        # Lua
        ''
          require("gitsigns").setup({
            signs = {
              add          = { text = "${icons.GitSign}" },
              change       = { text = "${icons.GitSign}" },
              delete       = { text = "${icons.GitSign}" },
              topdelete    = { text = "${icons.GitSign}" },
              changedelete = { text = "${icons.GitSign}" },
              untracked    = { text = "${icons.GitSign}" },
            },
            signs_staged = {
              add          = { text = "${icons.GitSign}" },
              change       = { text = "${icons.GitSign}" },
              delete       = { text = "${icons.GitSign}" },
              topdelete    = { text = "${icons.GitSign}" },
              changedelete = { text = "${icons.GitSign}" },
              untracked    = { text = "${icons.GitSign}" },
            },

            signs_staged_enable = true,
            signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
            numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
            linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
            word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
            watch_gitdir = {
              follow_files = true
            },
            auto_attach = true,
            attach_to_untracked = false,
            current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
            current_line_blame_opts = {
              virt_text = true,
              virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
              delay = 1000,
              ignore_whitespace = false,
              virt_text_priority = 100,
              use_focus = true,
            },
            current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
            blame_formatter = nil, -- Use default
            sign_priority = 6,
            update_debounce = 100,
            status_formatter = nil, -- Use default
            max_file_length = require("gabyx.config").large_buf_opts.lines, -- Disable if file is longer than this (in lines)

            preview_config = {
              -- Options passed to nvim_open_win
              style = 'minimal',
              relative = 'cursor',
              row = 0,
              col = 1
            },

            on_attach = function(bufnr)
              local gs = require("gitsigns")
              local function map(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
              end

              map("n", "<Leader>gl", function() gs.blame_line() end, "View blame.")
              map("n", "<Leader>gL", function() gs.blame_line { full = true } end, "View blame (full).")
              map("n", "<Leader>gp", function() gs.preview_hunk_inline() end, "Preview hunk.")
              map("n", "<Leader>gr", function() gs.reset_hunk() end, "Reset hunk.")
              map("v", "<Leader>gr", function() gs.reset_hunk { vim.fn.line ".", vim.fn.line "v" } end, "Reset hunk.")
              map("n", "<Leader>gR", function() gs.reset_buffer() end, "Reset file.")
              map("n", "<Leader>gs", function() gs.stage_hunk() end, "Stage/unstage hunk.")
              map("v", "<Leader>gs", function() gs.stage_hunk { vim.fn.line ".", vim.fn.line "v" } end, "Stage hunk.")
              map("n", "<Leader>gS", function() gs.stage_buffer() end, "Stage buffer.")
              map("n", "<Leader>gd", function() gs.diffthis() end, "View Diff.")

              map("n", "[G", function() gs.nav_hunk "first" end, "First hunk.")
              map("n", "]G", function() gs.nav_hunk "last" end, "Last hunk.")
              map("n", "]g", function() gs.nav_hunk "next" end, "Next hunk.")
              map("n", "[g", function() gs.nav_hunk "prev" end, "Previous hunk.")

              for _, mode in ipairs({ "o", "x" }) do
                map(mode, "ig", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk.")
              end
            end,
          })
        '';
    };
  };
}
