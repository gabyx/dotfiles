{ pkgs, ... }:
{
  vim.terminal.toggleterm = {
    enable = true;
    lazygit = {
      enable = true;

      package = pkgs.lazygit;

      mappings = {
        open = "<Leader>gg";
      };
    };
  };
}
