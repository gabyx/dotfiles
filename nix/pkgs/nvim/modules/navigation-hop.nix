{ pkgs, ... }:
let
  hop-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "hop.nvim";
    version = "2025-08-22";
    src = pkgs.fetchFromGitHub {
      owner = "smoka7";
      repo = "hop.nvim";
      rev = "707049feaca9ae65abb3696eff9aefc7879e66aa";
      sha256 = "0xzxl1mkdp1zyg9m97h2mhvb98fwwd21h5ki7jlhkb8cl294lx40";
    };
    meta.homepage = "https://github.com/smoka7/hop.nvim/";
  };
in
{
  vim.extraPlugins.hop = {
    package = hop-nvim;
    setup =
      # Lua
      ''
        require("hop").setup({
          multi_windows = true,
        })
      '';
  };

  vim.keymaps = [
    {
      key = "<Leader>jk";
      mode = [
        "n"
        "v"
      ];
      action = ":HopWord<CR>";
      desc = "Hop words.";
    }
    {
      key = "<Leader>jh";
      mode = [
        "n"
        "v"
      ];
      action = ":HopLineStart<CR>";
      desc = "Hop lines.";
    }
    {
      key = "<Leader>jc";
      mode = [
        "n"
        "v"
      ];
      action = ":HopChar2<CR>";
      desc = "Hop 2 chars.";
    }
    {
      key = "<Leader>jp";
      mode = [
        "n"
        "v"
      ];
      action = ":HopPattern<CR>";
      desc = "Hop pattern.";
    }
    {
      key = "<Leader>jP";
      mode = [
        "n"
        "v"
      ];
      action = ":HopPatternMW<CR>";
      desc = "Hop pattern over all buffers.";
    }
  ];
}
