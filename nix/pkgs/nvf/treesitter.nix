{ pkgs, lib, ... }:
let
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
      "incselect" = {
        package = incselect;
      };
    };

  vim.keymaps = [
    {
      key = "<CR>";
      action = "<cmd>lua require('incselect').init()<CR>";
      mode = [ "n" ];
    }
    {
      key = "<CR>";
      action = "<cmd>lua require('incselect').parent()<CR>";
      mode = [ "x" ];
    }
    {
      key = "<BS>";
      action = "<cmd>lua require('incselect').child()<CR>";
      mode = [ "x" ];
    }
  ];
}
