{ lib, ... }:
{
  vim.keymaps = [
    # Neovim Default LSP Mappings
    # {
    #   mode = [
    #     "n"
    #     "x"
    #   ];
    #   key = "gra";
    #   action = /* Lua */ ''
    #     function() vim.lsp.buf.code_action() end
    #   '';
    #   lua = true;
    #   desc = "vim.lsp.buf.code_action()";
    # }
    # {
    #   mode = "n";
    #   key = "grn";
    #   action = /* Lua */ ''
    #     function() vim.lsp.buf.rename() end
    #   '';
    #   lua = true;
    #   desc = "vim.lsp.buf.rename()";
    # }
    # {
    #   mode = "n";
    #   key = "grr";
    #   action = /* Lua */ ''
    #     function() vim.lsp.buf.references() end
    #   '';
    #   lua = true;
    #   desc = "vim.lsp.buf.references()";
    # }
    # {
    #   mode = "n";
    #   key = "gri";
    #   action = /* Lua */ "function() vim.lsp.buf.implementation() end";
    #   lua = true;
    #   desc = "vim.lsp.buf.implementation()";
    # }
    # {
    #   mode = "n";
    #   key = "gO";
    #   action = /* Lua */ ''
    #     function() vim.lsp.buf.document_symbol() end
    #   '';
    #   lua = true;
    #   desc = "vim.lsp.buf.document_symbol()";
    # }
    # {
    #   mode = [
    #     "i"
    #     "s"
    #   ];
    #   key = "<C-S>";
    #   action = /* Lua */ ''
    #     function() vim.lsp.buf.signature_help() end
    #   '';
    #   lua = true;
    #   desc = "vim.lsp.buf.signature_help()";
    # }

    # My normal mappings.
    {
      mode = [ "n" ];
      key = "<Leader>lo";
      lua = true;
      action = /* lua */ ''
        function() vim.cmd.split(vim.lsp.get_log_path()) end
      '';
      desc = "Open LSP log.";
    }
    {
      mode = "n";
      key = "<Leader>ld";
      lua = true;
      action = /* lua */ ''
        function() vim.diagnostic.open_float() end
      '';
      desc = "Show diagnostics.";
    }
  ];

  vim.autocmds = [
    {
      event = [ "LspAttach" ];
      desc = "Capability-gated LSP keymaps";

      callback = lib.generators.mkLuaInline /* lua */ ''
        function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end
          local buf = args.buf

          local function map(mode, key, fn, desc)
            vim.keymap.set(mode, key, fn, { buffer = buf, desc = desc })
          end

          local function has(method)
            return client:supports_method(method)
          end

          if has("textDocument/references") then
            map("n", "<Leader>lR", vim.lsp.buf.references, "Search references.")
          end

          if has("textDocument/rename") then
            map("n", "<Leader>lr", vim.lsp.buf.rename, "Rename current symbol.")
          end

          if has("textDocument/signatureHelp") then
            map("n", "<Leader>lh", vim.lsp.buf.signature_help, "Signature help.")
          end

          if has("textDocument/codeAction") then
            map({ "n", "x" }, "<Leader>la", vim.lsp.buf.code_action, "LSP code action.")
            map("n", "<Leader>lA", function()
              vim.lsp.buf.code_action { context = { only = { "source" }, diagnostics = {} } }
            end, "LSP source action")
          end

          if has("textDocument/codeLens") then
            map("n", "<Leader>ll", vim.lsp.codelens.refresh, "LSP CodeLens refresh")
            map("n", "<Leader>lL", vim.lsp.codelens.run, "LSP CodeLens run")
          end

          if has("textDocument/declaration") then
            map("n", "gD", vim.lsp.buf.declaration, "Declaration of current symbol")
          end

          if has("textDocument/definition") then
            map("n", "gd", vim.lsp.buf.definition, "Definition of current symbol")
          end

          if has("textDocument/typeDefinition") then
            map("n", "gy", vim.lsp.buf.type_definition, "Definition of current type.")
          end

          if has("workspace/symbol") then
            map("n", "<Leader>lG", vim.lsp.buf.workspace_symbol, "Search workspace symbols")
          end

          if has("textDocument/semanticTokens/full") and vim.lsp.semantic_tokens then
            map("n", "<Leader>uY",
              require("gabyxui.toggles").buffer_semantic_tokens(),
              "Toggle LSP semantic highlight (buffer)")
          end
        end
      '';
    }
  ];
}
