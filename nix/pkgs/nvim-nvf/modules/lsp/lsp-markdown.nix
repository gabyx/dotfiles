{
  ...
}:
{
  # Docker LSP derivation is backed. Thats fine.
  vim.lsp.servers.presets.marksman.enable = true;

  vim.lsp.servers.marksman = {
    filetypes = [
      "markdown"
    ];
  };
}
