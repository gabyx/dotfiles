{
  pkgs,
  ...
}:
let
  heirline-components-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "heirline-components.nvim";
    version = "2026-02-25";
    src = pkgs.fetchFromGitHub {
      owner = "Zeioth";
      repo = "heirline-components.nvim";
      rev = "5ea9a16286c01b7c36d58c91903d1f8ff0b7ddeb";
      sha256 = "0gij9c9qgmqc99fnqnvp6icxp32q0wkz536ric2x5vpbqlzsdkik";
    };
    meta.homepage = "https://github.com/Zeioth/heirline-components.nvim/";
    meta.hydraPlatforms = [ ];
  };
in
{
  vim.extraPlugins = {
    heirline-components = {
      package = heirline-components-nvim;
    };

    heirline = {
      package = pkgs.vimPlugins.heirline-nvim;
      setup =
        # lua
        ''
          echo "Setup heirline."
          lib = require("heirline-components")
          require("heirline").setup({

          })
        '';
    };
  };
}
