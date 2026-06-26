{ pkgs, ... }:
{

  # Inline NVIM render
  vim.lazy.plugins."markview.nvim" = {
    package = pkgs.vimPlugins.markview-nvim;

    lazy = true;
    ft = [ "markdown" ];
  };

  vim.lazy.plugins."markdown-preview.nvim" = {
    package = pkgs.vimPlugins.markdown-preview-nvim;

    lazy = true;
    ft = [ "markdown" ];
  };
  vim.extraPackages = [
    pkgs.nodejs-slim_latest
  ];
}
