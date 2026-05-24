---@type LazySpec
return {
  {
    lazy = true,
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },

    keys = {
      { "<Leader>gD", ":DiffviewOpen<cr>", desc = "Open Diffview." },
    },

    opts = function(_, opts)
      local actions = require("diffview.actions")
      return vim.tbl_deep_extend("force", opts, {
        keymaps = {
          view = {
            -- The `view` bindings are active in the diff buffers, only when the current
            -- tabpage is a Diffview.
            {
              "n",
              "<Leader>to",
              actions.conflict_choose("ours"),
              { desc = "Choose the OURS version of a conflict" },
            },
            {
              "n",
              "<Leader>tt",
              actions.conflict_choose("theirs"),
              { desc = "Choose the THEIRS version of a conflict" },
            },
            {
              "n",
              "<Leader>tb",
              actions.conflict_choose("base"),
              { desc = "Choose the BASE version of a conflict" },
            },
            {
              "n",
              "<Leader>ta",
              actions.conflict_choose("all"),
              { desc = "Choose all the versions of a conflict" },
            },
            {
              "n",
              "<Leader>tO",
              actions.conflict_choose_all("ours"),
              { desc = "Choose the OURS version of a conflict for the whole file" },
            },
            {
              "n",
              "<Leader>tT",
              actions.conflict_choose_all("theirs"),
              { desc = "Choose the THEIRS version of a conflict for the whole file" },
            },
            {
              "n",
              "<Leader>tB",
              actions.conflict_choose_all("base"),
              { desc = "Choose the BASE version of a conflict for the whole file" },
            },
            {
              "n",
              "<Leader>tA",
              actions.conflict_choose_all("all"),
              { desc = "Choose all the versions of a conflict for the whole file" },
            },
          },
        },
      })
    end,
  },
}
