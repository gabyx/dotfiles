{ ... }:
{

  vim.keymaps = [
    # Neovim Default LSP Mappings
    {
      mode = [
        "n"
        "x"
      ];
      key = "gra";
      action = /* Lua */ ''
        function() vim.lsp.buf.code_action() end
      '';
      lua = true;
      desc = "vim.lsp.buf.code_action()";
    }
    {
      mode = "n";
      key = "grn";
      action = /* Lua */ ''
        function() vim.lsp.buf.rename() end
      '';
      lua = true;
      desc = "vim.lsp.buf.rename()";
    }
    {
      mode = "n";
      key = "grr";
      action = /* Lua */ ''
        function() vim.lsp.buf.references() end
      '';
      lua = true;
      desc = "vim.lsp.buf.references()";
    }
    {
      mode = "n";
      key = "gri";
      action = /* Lua */ "function() vim.lsp.buf.implementation() end";
      lua = true;
      desc = "vim.lsp.buf.implementation()";
    }
    {
      mode = "n";
      key = "gO";
      action = /* Lua */ ''
        function() vim.lsp.buf.document_symbol() end
      '';
      lua = true;
      desc = "vim.lsp.buf.document_symbol()";
    }
    {
      mode = [
        "i"
        "s"
      ];
      key = "<C-S>";
      action = /* Lua */ ''
        function() vim.lsp.buf.signature_help() end
      '';
      lua = true;
      desc = "vim.lsp.buf.signature_help()";
    }
  ];
}
