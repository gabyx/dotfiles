{ lib, ... }:
let
  inherit (lib) types mkOption;
in
{
  options = {
    gabyx.lsp = {
      excludeDirs = mkOption {
        type = types.listOf types.str;
        description = "The exclude dirs for all LSP (if applicable).";
      };
    };
  };

  config = {
    vim.lsp.enable = true;

    vim.lsp.inlayHints.enable = false;

    vim.lsp.lspkind = {
      enable = true;
      setupOpts = {
        mode = "text_symbol";
      };
    };

    gabyx.lsp = {
      excludeDirs = [
        ".devenv"
        ".direnv"
        ".git"
        "target"
      ];
    };

    vim.keymaps = [
      # My normal mappings.
      {
        mode = [ "n" ];
        key = "<Leader>li";
        action = "<Cmd>checkhealth vim.lsp<CR>";
        desc = "Show LSP info.";
      }
      {
        mode = [ "n" ];
        key = "<Leader>lo";
        lua = true;
        action = /* lua */ ''
          function() vim.cmd.split(vim.lsp.log.get_filename()) end
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
      {
        mode = "n";
        key = "K";
        lua = true;
        action = /* lua */ ''
          function() vim.lsp.buf.hover() end
        '';
        desc = "LSP hover.";
      }
      {
        mode = "n";
        key = "<Leader>uh";
        lua = true;
        action = /* Lua */ ''
          function() require("gabyx").toggles.buffer_inlay_hints() end
        '';
        desc = "Toggle LSP inlay hints (buffer).";
      }
      {
        mode = "n";
        key = "<Leader>uH";
        lua = true;
        action = /* Lua */ ''
          function() require("gabyx").toggles.inlay_hints() end
        '';
        desc = "Toggle LSP inlay hints.";
      }

    ];

    vim.lsp.mappings = {
      goToDefinition = "gd";
      goToDeclaration = "gD";
      goToType = "gy";
      listImplementations = "<leader>lI";
      listReferences = "<leader>lR";
      nextDiagnostic = "[d";
      previousDiagnostic = "]d";
      openDiagnosticFloat = "<leader>ld";
      documentHighlight = "<leader>lH";
      listDocumentSymbols = "<leader>lS";
      addWorkspaceFolder = null;
      removeWorkspaceFolder = null;
      listWorkspaceFolders = "<leader>lF";
      listWorkspaceSymbols = "<leader>lG";
      hover = "<leader>lh";
      signatureHelp = "<leader>ls";
      renameSymbol = "<leader>lr";
      codeAction = "<leader>la";
      format = "<leader>lf";
      toggleFormatOnSave = null;
    };

    vim.binds.whichKey.register = {
      "gd" = "Definition of current symbol.";
      "gD" = "Declaration of current symbol.";
      "gy" = "Definition of current type.";
      "<leader>lI" = "Implementations of current symbol.";
      "<leader>lR" = "References of current symbol.";
      "[d" = "Next diagnostics.";
      "]d" = "Previous diagnostics.";
      "<leader>ld" = "Show diagnostics.";
      "<leader>lH" = "Show document highlight.";
      "<leader>lS" = "Show document symbols.";
      "<leader>lF" = "Show workspace folder.";
      "<leader>lG" = "Show workspace symbols.";
      "<leader>lh" = "Hover help.";
      "<leader>ls" = "Signature help";
      "<leader>lr" = "Rename symbol.";
      "<leader>la" = "Code action.";
      "<leader>lf" = "Format over LSP";
    };
  };
}
