{
  ...
}:
{
  # LSP derivation is backed. Thats fine.
  vim.lsp.servers.presets.bash-language-server.enable = true;

  vim.lsp.servers.bash-language-server = {
    filetypes = [
      "sh"
    ];
  };
}
