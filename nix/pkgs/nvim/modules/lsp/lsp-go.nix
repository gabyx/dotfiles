{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.generators) mkLuaInline;
  inherit (import ./lsp-resolve-cmd.lib.nix { inherit pkgs; }) resolveCmd;
in
{
  vim.lsp.presets.gopls.enable = true;
  vim.lsp.servers.gopls = {
    enable = true;
    cmd = lib.mkForce [
      (resolveCmd "gopls")
    ];

    filetypes = [
      "go"
      "gomod"
      "gosum"
      "gowork"
    ];

    # Also not defined, gets merged into a `vim.lsp.config`
    settings = {
      gopls = {
        analyses = {
          ST1003 = true;
          fieldalignment = false;
          fillreturns = true;
          nilness = true;
          nonewvars = true;
          shadow = true;
          undeclaredname = true;
          unreachable = true;
          unusedparams = true;
          unusedwrite = true;
          useany = true;
        };

        codelenses = {
          gc_details = true; # toggle display of gc's choices
          generate = true; # the `go generate` lens
          regenerate_cgo = true;
          test = true;
          tidy = true;
          upgrade_dependency = true;
          vendor = true;
        };

        hints = {
          assignVariableTypes = true;
          compositeLiteralFields = true;
          compositeLiteralTypes = true;
          constantValues = true;
          functionTypeParameters = true;
          parameterNames = true;
          rangeVariableTypes = true;
        };

        buildFlags = [
          "-tags"
          "test,test_small,test_large,test_all,unittest,integration,test_integration,test_endpoints"
        ];

        completeUnimported = true;
        diagnosticsDelay = "500ms";
        matcher = "Fuzzy";
        semanticTokens = true;
        staticcheck = true;
        symbolMatcher = "fuzzy";
        usePlaceholders = true;
      };
    };
  };

  vim.lsp.servers.golangci-lint-ls = {
    enable = true;
    cmd = [ "golangci-lint-langserver" ];

    filetypes = [
      "go"
      "gomod"
    ];

    init_options.command = [
      "golangci-lint"
      "run"
      # silence any output sinks the user's .golangci.yml might turn on
      "--output.text.path="
      "--output.tab.path="
      "--output.html.path="
      "--output.checkstyle.path="
      "--output.junit-xml.path="
      "--output.teamcity.path="
      "--output.sarif.path="
      "--show-stats=false"
      # JSON on stdout is what the langserver actually consumes
      "--output.json.path=stdout"
    ];

    root_dir = lib.generators.mkLuaInline /* lua */ ''
      function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local markers = {
          ".golangci.yml", ".golangci.yaml", ".golangci.toml", ".golangci.json",
          "go.work", "go.mod", ".git",
        }

        for _, m in ipairs(markers) do
          local root = vim.fs.root(fname, m)
          if root then
            on_dir(root)
            return
          end
        end
      end
    '';
  };
}
