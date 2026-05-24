---@type LazySpec
return {
  {
    "nvim-pack/nvim-spectre",
    keys = {
      {
        "<Leader>sw",
        function()
          require("spectre").open_visual({ select_word = true })
        end,
        desc = "Search current word.",
      },
      {
        "<Leader>sw",
        function()
          require("spectre").open_visual()
        end,
        desc = "Search current word.",
        mode = "v",
      },
      {
        "<Leader>sp",
        function()
          require("spectre").open_file_search({ select_word = true })
        end,
        desc = "Search current word in file.",
      },
      {
        "<Leader>sS",
        function()
          require("spectre").toggle()
        end,
        desc = "Search with Spectre",
      },
    },
  },
}
