{
  ...
}:
{
  # LSP derivation is backed. Thats fine.
  vim.lsp.servers.lua-language-server.enable = true;

  vim.lsp.servers.lua-language-server = {
    filetypes = [
      "lua"
    ];
  };
}
