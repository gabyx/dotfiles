{ lib, ... }:
let
  inherit (lib.generators) mkLuaInline;
in
{
  # We dont want formatting over the LSP.
  # Cause formatting is a global operation and
  # separating concerns is more stable.
  vim.languages.enableFormat = false;
  vim.lsp.formatOnSave = false;

  vim.formatter.conform-nvim = {
    enable = true;

    setupOpts = {
      default_format_opts = {
        lsp_format = "fallback";
      };

      format_after_save = null;

      format_on_save =
        mkLuaInline
          # Lua
          ''
            function()
              if not require("gabyx.format").on_save_enabled() then
                return
              end
            end
          '';

      formatters_by_ft = {
        typescriptreact = [ "prettier" ];
        javascriptreact = [ "prettier" ];
        javascript = [ "prettier" ];
        typescript = [ "prettier" ];
        json = [ "prettier" ];
        jsonc = [ "prettier" ];
        html = [ "prettier" ];
        css = [ "prettier" ];
        scss = [ "prettier" ];
        graphql = [ "prettier" ];
        markdown = [ "prettier" ];
        vue = [ "prettier" ];
        astro = [ "prettier" ];
        yaml = [ "prettier" ];

        go = [
          "gofmt"
          "goimports"
          "golines"
        ]; # run sequentially, golines last
        cpp = [ "clang_format" ]; # note: underscore, not "clangformat"
        rust = [ "rustfmt" ];

        sql = [ "sqlfluff" ];

        starlark = [
          "black"
        ];
        python = [
          "ruff"
          "isort"
        ];

        sh = [ "shfmt" ];
        lua = [ "stylua" ];
        nix = [ "nixfmt" ];
        nu = [ "nufmt" ];

        # "*" runs on every filetype
        # "_" runs on all filetypes which have no formatter.
        "*" = [ "trim_whitespace" ];
      };

      formatters = {
        golines.prepend_args = [ "--no-reformat-tags" ];

        sqlfluff = {
          command = "sqlfluff";
          args = [
            "format"
            "--disable-progress-bar"
            "--nocolor"
            "-"
          ];
          stdin = true;
          cwd =
            mkLuaInline
              # Lua
              ''
                require("conform.util").root_file({
                  ".sqlfluff", "setup.cfg", "tox.ini", "pep8.ini", "pyproject.toml",
                })
              '';
        };
      };
    };

  };
}
