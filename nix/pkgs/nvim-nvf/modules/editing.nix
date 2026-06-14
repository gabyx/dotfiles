{ pkgs, ... }:
{
  vim.extraPlugins.nvim-surround = {
    package = pkgs.vimPlugins.nvim-surround;

    setup =
      # Lua
      ''
        require("nvim-surround").setup({})
      '';
  };
}
