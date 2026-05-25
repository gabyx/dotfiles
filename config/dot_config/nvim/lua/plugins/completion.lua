---@type LazySpec
return {
  {
    "Saghen/blink.cmp",
    opts = {
      prebuilt_binaries = {
        download = false,
      },
    },
  },
  -- Adding emoji completion.
  {
    "moyiz/blink-emoji.nvim",
    lazy = true,
    specs = {
      {
        "Saghen/blink.cmp",
        optional = true,
        opts = {
          sources = {
            -- enable the provider by default (automatically extends when merging tables)
            default = { "emoji" },
            providers = {
              -- Specific details depend on the blink source
              emoji = {
                name = "Emoji",
                module = "blink-emoji",
                min_keyword_length = 1,
                score_offset = -1,
              },
            },
          },
        },
      },
    },
  },
}
