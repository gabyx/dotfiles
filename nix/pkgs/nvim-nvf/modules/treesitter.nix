{ lib, pkgs, ... }:
let
  inherit (lib.generators) mkLuaInline;
in
{
  vim.treesitter = {
    enable = true;
    grammars = pkgs.vimPlugins.nvim-treesitter.allGrammars;
    addDefaultGrammars = true;

    context = {
      enable = true;
      setupOpts = {
        multiline_threshold = 10;
        separator = null;
      };
    };

    fold = false;

    autotagHtml = true;

    highlight = {
      enable = true;
    };

    indent.enable = true;
    textobjects.enable = true;
  };

  vim.highlight.TreesitterContextBottom = {
    underline = true;
    sp = "#d1cf00";
  };

  vim.extraPackages = [
    pkgs.tree-sitter
  ];

  vim.extraPlugins =
    let
      incselect = pkgs.vimUtils.buildVimPlugin {
        name = "inclselect.nvim";
        src = pkgs.fetchFromGitHub {
          owner = "shushtain";
          repo = "incselect.nvim";
          rev = "723b6bcf451134dc652f2c41b86bcf15b69747c0"; # use a commit hash for reproducibility
          hash = "sha256-JPPgpDvBG0kJ/Sxfllq0KRvD49zGogGxjocufixw4mk=";
        };
      };
    in
    {
      incselect = {
        package = incselect;
      };
    };

  vim.keymaps = [
    {
      key = "<CR>";
      lua = true;
      action = /* lua */ ''
        function()
          require('incselect').parent()
        end
      '';
      mode = [ "x" ];
    }
    {
      key = "<BS>";
      lua = true;
      action = /* lua */ ''
        function()
          require('incselect').child()
        end
      '';
      mode = [ "x" ];
    }
  ];

  # Normal-mode <CR> is only bound per-buffer, and only when a
  # tree-sitter parser is actually attached to that buffer.
  # This avoids ever mapping a global <CR> in other buffers where this is not wanted like
  # qf, neo-tree, trouble, help, terminal, etc.
  # those keep whatever mapping they already have.
  vim.augroups = [
    {
      enable = true;
      name = "incselect-init";
      clear = true;
    }
  ];
  vim.autocmds = [
    {
      event = [ "FileType" ];
      group = "incselect-init";
      enable = true;
      desc = "incselect init by <CR>";
      callback = mkLuaInline /* lua */ ''
        function(ev)
          local gabyx = require("gabyx")

          if gabyx.buffer.has_treesitter_parser(ev.buf) then
            vim.keymap.set("n", "<CR>", function()
              if not require("incselect").init() then
                gabyx.notify(
                    "Could not install incselect init.",
                    vim.log.levels.WARN
                )
                vim.cmd("normal! \r")
              end
            end, { buffer = ev.buf, silent = true, desc = "incselect init" })

          end
        end
      '';
    }
  ];
}
