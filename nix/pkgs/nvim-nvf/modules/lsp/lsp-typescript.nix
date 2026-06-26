{
  ...
}:
{
  # LSP derivation is backed. Thats fine.
  vim.lsp.presets.typescript-go.enable = true;

  vim.lsp.servers.typescript-go = {
    filetypes = [
      "typescript"
    ];
  };
}
