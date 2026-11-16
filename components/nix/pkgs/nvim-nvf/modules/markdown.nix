{ pkgs, lib, ... }:
{

  # Inline NVIM render with `Markview toggle`.
  vim.lazy.plugins."markview.nvim" = {
    package = pkgs.vimPlugins.markview-nvim;

    lazy = true;

    setupModule = "markview";
    setupOpts = lib.mkLuaInline ''
      {
        preview = {
          enable = false,
          hybrid_modes = { "n" },
        }
      }
    '';

    ft = [ "markdown" ];
  };

  # Markdown browser render with `MarkdownPreview`.
  vim.lazy.plugins."markdown-preview.nvim" = {
    package = pkgs.vimPlugins.markdown-preview-nvim;

    lazy = true;
    ft = [ "markdown" ];
  };
  vim.extraPackages = [
    pkgs.nodejs-slim_latest
  ];
}
