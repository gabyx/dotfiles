{ lib, ... }:
let
  inherit (lib.generators) mkLuaInline toLua;

  defaultFormatters = [ "trim_whitespace" ];

  # Prefer treefmt when a 'treefmt' config is present for the buffer,
  # otherwise fall back to the given per-filetype formatter list.
  tf =
    fallback:
    mkLuaInline
      # Lua
      ''
        function(bufnr)
          if require("conform").get_formatter_info("treefmt", bufnr).available then
            return ${toLua { } ([ "treefmt" ] ++ defaultFormatters)}
          end
          return ${toLua { } fallback}
        end
      '';
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

      notify_on_error = true;
      notify_no_formatters = true;

      format_after_save = null;

      format_on_save =
        mkLuaInline
          # Lua
          ''
            function(bufnr)
              if (vim.b[bufnr].format_on_save ~= nil and
                not vim.b[bufnr].format_on_save) or
                not require("gabyx").config.toggles.format_on_save then
                return
              end

              fmt = require("conform").list_formatters_to_run(bufnr)
              local names = ""
              for _, item in ipairs(fmt) do
                  names = names .. "\n- '" .. item.name .. "'"
              end

              vim.notify("Formatting file with:" .. names)

              return { timeout_ms = 500 }
            end
          '';

      formatters_by_ft = {
        typescriptreact = tf [ "prettier" ];
        javascriptreact = tf [ "prettier" ];
        javascript = tf [ "prettier" ];
        typescript = tf [ "prettier" ];
        json = tf [ "prettier" ];
        jsonc = tf [ "prettier" ];
        html = tf [ "prettier" ];
        css = tf [ "prettier" ];
        scss = tf [ "prettier" ];
        graphql = tf [ "prettier" ];
        markdown = tf [ "prettier" ];
        vue = tf [ "prettier" ];
        astro = tf [ "prettier" ];
        yaml = tf [ "prettier" ];

        go = tf [
          "gofmt"
          "goimports"
          "golines"
        ]; # run sequentially, golines last
        cpp = tf [ "clang_format" ]; # note: underscore, not "clangformat"
        rust = tf [ "rustfmt" ];

        sql = tf [ "sqlfluff" ];

        starlark = tf [
          "black"
        ];
        python = tf [
          "ruff"
          "isort"
        ];

        sh = tf [ "shfmt" ];
        lua = tf [ "stylua" ];
        nix = tf [ "nixfmt" ];
        nu = tf [ "nufmt" ];

        # "*" runs on every filetype
        # "_" runs on all filetypes which have no formatter.
        "*" = defaultFormatters;
      };

      formatters = {
        treefmt = {
          command = "treefmt";
          cwd = false;
          args = [ ];
          stdin = false;
        };

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
