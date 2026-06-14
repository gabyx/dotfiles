{ lib, ... }:
let
  codeSnippets = ../config/snippets;
in
{
  vim.snippets.luasnip = {
    enable = true;

    providers = [ ];

    loaders =
      # Lua
      ''
        require("luasnip.loaders.from_vscode").lazy_load({
          paths = {
            vim.fn.stdpath("config") .. "/snippets",
            "${codeSnippets}"
          },
        })

        require("gabyx.snippets.all")
      '';
  };
}
