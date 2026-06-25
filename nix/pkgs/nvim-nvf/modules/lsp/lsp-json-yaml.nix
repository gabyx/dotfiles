{
  ...
}:
{
  # LSP derivation is backed. Thats fine.
  vim.lsp.servers.presets.yaml-langauge-server.enable = true;
  vim.lsp.servers.presets.json-langauge-server.enable = true;

  vim.lsp.servers.yaml-language-server = {
    filetypes = [
      "yaml"
    ];
  };

  vim.lsp.servers.json-language-server = {
    filetypes = [
      "json"
    ];
  };

}
