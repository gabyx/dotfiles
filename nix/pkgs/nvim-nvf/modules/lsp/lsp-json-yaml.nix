{
  ...
}:
{
  # LSP derivation is backed. Thats fine.
  vim.lsp.presets.yaml-language-server.enable = true;
  vim.lsp.presets.vscode-json-language-server.enable = true;

  vim.lsp.servers.yaml-language-server = {
    filetypes = [
      "yaml"
    ];
  };

  vim.lsp.servers.vscode-json-language-server = {
    filetypes = [
      "json"
    ];
  };

}
