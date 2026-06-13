{ ... }:
{
  vim.snippets.luasnip = {
    enable = true;

    providers = [ ];

    loaders =
      # Lua
      ''
        require("luasnip.loaders.from_vscode").lazy_load({})

        require("gabyx.snippets.all")
      '';
  };
}
