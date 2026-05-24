---@type LazySpec
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

          -- Modifiers:
          -- Alt: A-
          -- Shift: S-
          -- Control: C-
          -- Super: D-
          -- Meta: T-

          ["<Leader>b"] = { name = "Buffers" },
          ["<Leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
          ["<Leader>bD"] = {
            function()
              require("astroui.status").heirline.buffer_picker(function(bufnr)
                require("astrocore.buffer").close(bufnr)
              end)
            end,
            desc = "Pick to close",
          },

          -- Save all files.
          ["<Leader>wa"] = { ":wa!<cr>", desc = "Save all files" },

          -- Search commands.
          ["<Leader>s"] = { name = "Search" },

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

          -- Base64 commands.
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

        x = {},
        t = {},
      },
    },
  },
}
