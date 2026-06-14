{ pkgs, ... }:
{
  vim.extraPlugins = {
    gomove = {
      package = pkgs.vimPlugins.nvim-gomove;
      setup =
        # lua
        ''
          require("gomove").setup({
              -- whether or not to map default key bindings, (true/false)
              map_defaults = false,
              -- whether or not to reindent lines moved vertically (true/false)
              reindent = true,
              -- whether or not to undojoin same direction moves (true/false)
              undojoin = true,
              -- whether to not to move past end column when moving blocks horizontally, (true/false)
              move_past_end_col = false,
            })
        '';
    };
  };
  vim.keymaps = [
    # Normal mode — move
    {
      mode = "n";
      key = "<S-Left>";
      action = "<Plug>GoNSMLeft";
      noremap = true;
    }
    {
      mode = "n";
      key = "<S-Up>";
      action = "<Plug>GoNSMUp";
      noremap = true;
    }
    {
      mode = "n";
      key = "<S-Down>";
      action = "<Plug>GoNSMDown";
      noremap = true;
    }
    {
      mode = "n";
      key = "<S-Right>";
      action = "<Plug>GoNSMRight";
      noremap = true;
    }

    # Normal mode — duplicate
    {
      mode = "n";
      key = "<S-C-Left>";
      action = "<Plug>GoNSDLeft";
      noremap = true;
    }
    {
      mode = "n";
      key = "<S-C-Down>";
      action = "<Plug>GoNSDDown";
      noremap = true;
    }
    {
      mode = "n";
      key = "<S-C-Up>";
      action = "<Plug>GoNSDUp";
      noremap = true;
    }
    {
      mode = "n";
      key = "<S-C-Right>";
      action = "<Plug>GoNSDRight";
      noremap = true;
    }

    # Visual/select mode — move
    {
      mode = "x";
      key = "<S-Left>";
      action = "<Plug>GoVSMLeft";
      noremap = true;
    }
    {
      mode = "x";
      key = "<S-Down>";
      action = "<Plug>GoVSMDown";
      noremap = true;
    }
    {
      mode = "x";
      key = "<S-Up>";
      action = "<Plug>GoVSMUp";
      noremap = true;
    }
    {
      mode = "x";
      key = "<S-Right>";
      action = "<Plug>GoVSMRight";
      noremap = true;
    }

    # Visual/select mode — duplicate
    {
      mode = "x";
      key = "<S-C-Left>";
      action = "<Plug>GoVSDLeft";
      noremap = true;
    }
    {
      mode = "x";
      key = "<S-C-Down>";
      action = "<Plug>GoVSDDown";
      noremap = true;
    }
    {
      mode = "x";
      key = "<S-C-Up>";
      action = "<Plug>GoVSDUp";
      noremap = true;
    }
    {
      mode = "x";
      key = "<S-C-Right>";
      action = "<Plug>GoVSDRight";
      noremap = true;
    }
  ];
}
