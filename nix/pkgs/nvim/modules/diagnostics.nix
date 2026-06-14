{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.gabyx) icons;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.binds) mkKeymap;
in
{
  vim.diagnostics = {
    enable = true;

    config =
      let
        severityIcons = /* lua */ ''
          {
            [vim.diagnostic.severity.ERROR] = "${icons.DiagnosticError}",
            [vim.diagnostic.severity.WARN]  = "${icons.DiagnosticWarn}",
            [vim.diagnostic.severity.INFO]  = "${icons.DiagnosticInfo}",
            [vim.diagnostic.severity.HINT]  = "${icons.DiagnosticHint}",
          }
        '';
      in
      {
        virtual_text = {
          prefix =
            mkLuaInline
              # Lua
              ''
                function(diagnostic)
                  local severity_icons = ${severityIcons}
                  return severity_icons[diagnostic.severity] or "●"
                end
              '';
          spacing = 2;
          source = "if_many";
        };

        signs = true;
        underline = true;
        update_in_insert = false;
        severity_sort = true;

        sign.text = mkLuaInline severityIcons;
      };
  };

  vim = {
    lazy.plugins."trouble.nvim" = {
      lazy = false;
      package = pkgs.vimPlugins.trouble-nvim;

      setupModule = "trouble";

      cmd = "Trouble";

      keys = [
        (mkKeymap "n" "<Leader>xx" "<cmd>Trouble toggle diagnostics<CR>" {
          desc = "Workspace diagnostics.";
        })
        (mkKeymap "n" "<Leader>xb" "<cmd>Trouble toggle diagnostics filter.buf=0<CR>" {
          desc = "Buffer diagnostics.";
        })
        (mkKeymap "n" "<Leader>xq" "<cmd>Trouble toggle quickfix<CR>" {
          desc = "Quickfix.";
        })
        (mkKeymap "n" "<Leader>xl" "<cmd>Trouble toggle loclist<CR>" {
          desc = "LOC";
        })
      ];
    };
  };

  vim.keymaps = [
    {
      mode = "n";
      key = "[e";
      lua = true;
      action = /* lua */ ''
        function() require("gabyx.diagnostics").jump(false, "ERROR") end
      '';
      desc = "Previous error.";
    }
    {
      mode = "n";
      key = "]e";
      lua = true;
      action = /* lua */ ''
        function() require("gabyx.diagnostics").jump(true, "ERROR") end
      '';
      desc = "Next error.";
    }
    {
      mode = "n";
      key = "[w";
      lua = true;
      action = /* lua */ ''
        function() require("gabyx.diagnostics").jump(false, "WARN") end
      '';
      desc = "Previous warning.";
    }
    {
      mode = "n";
      key = "]w";
      lua = true;
      action = /* lua */ ''
        function() require("gabyx.diagnostics").jump(true, "WARN") end
      '';
      desc = "Next warning.";
    }
  ];

}
