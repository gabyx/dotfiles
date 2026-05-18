return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          -- No clipboard override when pressing c, x or Del.
          ["s"] = { '"_s', remap = false },
          ["S"] = { '"_S', remap = false },
          ["x"] = { '"_x', remap = false },
          ["X"] = { '"_x', remap = false },
          ["c"] = { '"_c', remap = false },
          ["C"] = { '"_c', remap = false },
          ["<Del>"] = { '"_x', remap = false },

          ["<Leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
          ["<Leader>bD"] = {
            function()
              require("astroui.status").heirline.buffer_picker(function(bufnr)
                require("astrocore.buffer").close(bufnr)
              end)
            end,
            desc = "Pick to close",
          },
          -- tables with the `name` key will be registered with which-key if it's installed
          -- this is useful for naming menus.
          --
          -- Modifiers:
          -- Alt: A-
          -- Shift: S-
          -- Control: C-
          -- Super: D-
          -- Meta: T-

          ["<Leader>b"] = { name = "Buffers" },

          -- Search Git files.
          ["<Leader>fg"] = {
            ":Telescope git_files<cr>",
            desc = "Find Git files",
          },
          -- Save all files.
          ["<Leader>wa"] = { ":wa!<cr>", desc = "Save all files" },

          -- Undo Tree toggle.
          ["<Leader>bu"] = {
            function()
              vim.cmd.UndotreeToggle()
            end,
            desc = "Show Undo Tree",
          },

          -- Git stuff.
          ["<Leader>gD"] = { ":DiffviewOpen<CR>", desc = "Open Diffview." },

          ["<Leader>as"] = {
            "<cmd>Telescope cmdline<cr>",
            desc = "Open cmdline.",
          },

          -- Select and move inside AST.
          ["<Leader>ba"] = {
            function()
              require("tsht").nodes()
            end,
            desc = "Select in AST.",
          },
          ["<Leader>bA"] = {
            function()
              require("tsht").move()
            end,
            desc = "Move in AST.",
          },

          -- UI commands.
          ["<Leader>uT"] = {
            ":TSContextToggle<cr>",
            desc = "Treesitter Context",
          },

          ["<Leader>u."] = {
            function()
              require("user.util.format-on-save").toggle_format_on_save()
            end,
            desc = "Toggle Format On Save",
          },

          -- Search commands.
          ["<Leader>s"] = { name = "Search" },

          -- Debug Adapter commands.
          ["<Leader>dl"] = {
            ":vsplit ~/.cache/nvim/dap.log",
            desc = "DAP log.",
          },

          -- File commands.
          ["<Leader>b."] = {
            ":echo expand('%:p')<cr>",
            desc = "Show Buffer Path",
          },

          -- Apply commands.
          ["<Leader>a"] = { name = "Apply Commands and Macros" },
          ["<Leader>am"] = {
            ":. norm @<macro-name>",
            desc = "Apply macro at current line.",
          },
          ["<Leader>ac"] = {
            ":. !<sh-cmd>",
            desc = "Apply command at current line.",
          },

          -- Show all diagnostics with Trouble.
          ["<Leader>xx"] = {
            ":Trouble diagnostics toggle<cr>",
          },

          -- Format commands.
          ["<Leader>bf"] = {
            ":FormatWriteLock<cr>",
            desc = "Format current buffer.",
          },

          -- Gomove plugin
          ["<S-Left>"] = { "<Plug>GoNSMLeft", remap = false },
          ["<S-Up>"] = { "<Plug>GoNSMUp", remap = false },
          ["<S-Down>"] = { "<Plug>GoNSMDown", remap = false },
          ["<S-Right>"] = { "<Plug>GoNSMRight", remap = false },
          ["<S-C-Left>"] = { "<Plug>GoNSDLeft", remap = false },
          ["<S-C-Down>"] = { "<Plug>GoNSDDown", remap = false },
          ["<S-C-Up>"] = { "<Plug>GoNSDUp", remap = false },
          ["<S-C-Right>"] = { "<Plug>GoNSDRight", remap = false },
        },

        v = {

          -- No clipboard override when pressing c, s or Del.
          ["s"] = { '"_s', remap = false },
          ["S"] = { '"_S', remap = false },
          ["c"] = { '"_c', remap = false },
          ["C"] = { '"_c', remap = false },
          ["<Del>"] = { '"_x', remap = false },
          -- No clipboard overwrite (reselect and yank again)
          -- when pasting in visual mode.
          ["p"] = { "pgvy", remap = false },

          -- Refactoring plugin.
          ["<Leader>r"] = { name = "Refactoring" },
          ["<Leader>rr"] = {
            "<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>",
          },

          -- Apply commands.
          ["<Leader>a"] = { name = "Apply Commands and Macros" },
          ["<Leader>am"] = {
            ":norm @<macro-name>",
            desc = "Apply macro over the selected lines.",
          },
          ["<Leader>ac"] = {
            ":!<sh-cmd>",
            desc = "Apply command over the selected lines.",
          },

          ["<Leader>b"] = { name = "Base64 Encode/Decode" },
          ["<Leader>be"] = {
            "c<C-R>=system('base64 --wrap=0', @\")<cr><esc>",
            desc = "Base64 Encode",
          },
          ["<Leader>bd"] = {
            "c<C-R>=system('base64 -d --wrap=0', @\")<cr><esc>",
            desc = "Base64 Decode",
          },
        },

        [{ "n", "v" }] = {
          -- Harpoon commands.
          ["<Leader>jf"] = {
            ':lua require("harpoon.ui").toggle_quick_menu()<CR>',
            desc = "Harpoon list.",
          },
          ["<Leader>jj"] = {
            ':lua require("harpoon.mark").add_file()<CR>',
            desc = "Add to harpoon list.",
          },
          ["<S-h>"] = {
            ':lua require("harpoon.ui").nav_next()<CR>',
            desc = "Next harpoon file.",
          },
          ["<S-l>"] = {
            ':lua require("harpoon.ui").nav_prev()<CR>',
            desc = "Previous harpoon file.",
          },

          -- Hop commands.
          ["<Leader>jk"] = { ":HopWord<CR>", desc = "Hop words." },
          ["<Leader>jh"] = { ":HopLine<CR>", desc = "Hop lines." },
        },

        x = {
          ["<S-Left>"] = { "<Plug>GoVSMLeft", remap = false },
          ["<S-Down>"] = { "<Plug>GoVSMDown", remap = false },
          ["<S-Up>"] = { "<Plug>GoVSMUp", remap = false },
          ["<S-Right>"] = { "<Plug>GoVSMRight", remap = false },
          ["<S-C-Left>"] = { "<Plug>GoVSDLeft", remap = false },
          ["<S-C-Down>"] = { "<Plug>GoVSDDown", remap = false },
          ["<S-C-Up>"] = { "<Plug>GoVSDUp", remap = false },
          ["<S-C-Right>"] = { "<Plug>GoVSDRight", remap = false },
        },

        t = {
          -- setting a mapping to false will disable it
          -- ["<esc>"] = false,
        },
      },
    },
  },
}
