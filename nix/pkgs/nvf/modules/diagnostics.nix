{ lib, pkgs, ... }:
let
  inherit (lib.nvim.binds) mkKeymap;
in
{
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
      action = /* Lua */ ''
        function() require("gabyx.diagnostics").jump(false, "ERROR") end
      '';
      desc = "Previous error.";
    }
    {
      mode = "n";
      key = "]e";
      lua = true;
      action = /* Lua */ ''
        function() require("gabyx.diagnostics").jump(true, "ERROR") end
      '';
      desc = "Next error.";
    }
    {
      mode = "n";
      key = "[w";
      lua = true;
      action = /* Lua */ ''
        function() require("gabyx.diagnostics").jump(false, "WARN") end
      '';
      desc = "Previous warning.";
    }
    {
      mode = "n";
      key = "]w";
      lua = true;
      action = /* Lua */ ''
        function() require("gabyx.diagnostics").jump(true, "WARN") end
      '';
      desc = "Next warning.";
    }
  ];

}
