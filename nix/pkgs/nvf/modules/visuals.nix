{ pkgs, ... }:
{
  vim.extraPlugins = {
    cellular-automaton = {
      package = pkgs.vimPlugins.cellular-automaton-nvim;
    };
  };

  vim.lazy = {
    enable = true;

    # Enable visual whitespace on visual select.
    plugins."visual-whitespace.nvim" = {
      package = pkgs.vimPlugins.visual-whitespace-nvim;
      event = [
        {
          event = "ModeChanged";
          # \22 is Ctrl-V (visual-block, byte 0x16) but not possible in `nix`.
          pattern = "*:[vV]";
        }
      ];
    };
  };

  vim.keymaps = [
    {
      key = "<Leader>uw";
      mode = [
        "n"
        "v"
      ];
      action = /* Lua */ ''
        function() require("visual-whitespace").toggle() end
      '';
      lua = true;
      desc = "Toggle visual whitespace.";
    }
    {
      key = "<Leader>sff";
      mode = [ "n" ];
      action = ":CellularAutomaton make_it_rain<cr>";
      desc = "Fall fall my letters.";
    }
  ];
}
