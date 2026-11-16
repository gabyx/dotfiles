{
  ...
}:
{
  # LSP derivation is backed. Thats fine.
  vim.lsp.presets.nushell.enable = true;

  vim.lsp.servers.nushell = {
    filetypes = [
      "nu"
    ];
  };
}
