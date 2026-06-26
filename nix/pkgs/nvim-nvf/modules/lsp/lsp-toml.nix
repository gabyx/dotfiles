{
  ...
}:
{
  # LSP derivation is backed. Thats fine.
  vim.lsp.presets.taplo.enable = true;

  vim.lsp.servers.taplo = {
    filetypes = [
      "toml"
    ];
  };
}
