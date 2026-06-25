{
  ...
}:
{
  # LSP derivation is backed. Thats fine.
  vim.lsp.servers.presets.docker-language-server.enable = true;

  vim.lsp.servers.docker-language-server = {
    filetypes = [
      "dockerfile"
      "yaml.docker-compose"
    ];
  };

  vim.filetype = {
    pattern = {
      ".*/?docker%-compose%.ya?ml" = "yaml.docker-compose";
      ".*/?compose%.ya?ml" = "yaml.docker-compose";
    };
  };
}
