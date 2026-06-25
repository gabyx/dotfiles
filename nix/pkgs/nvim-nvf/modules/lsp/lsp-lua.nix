{
  ...
}:
{
  # LSP derivation is backed. Thats fine.
  vim.lsp.servers.presets.lua-language-server.enable = true;

  vim.lsp.servers.lua-language-server = {
    filetypes = [
      "lua"
    ];
  };
}
