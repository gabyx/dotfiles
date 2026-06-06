{ pkgs, ... }:
{
  vim.extraPlugins = {
    nvim-config-local = {
      package = pkgs.vimPlugins.nvim-config-local;

      setup =
        # Lua
        ''
          opts = {
            -- Config file patterns to load (lua supported)
            config_files = { ".nvim/nvim.lua" },

            -- Where the plugin keeps files data
            hashfile = vim.fn.stdpath("data") .. "/nvim-config-local",

            autocommands_create = true, -- Create autocommands (VimEnter, DirectoryChanged)
            commands_create = true,     -- Create commands (ConfigLocalSource, ConfigLocalEdit, ConfigLocalTrust, ConfigLocalIgnore)
            silent = false,             -- Disable plugin messages (Config loaded/ignored)
            lookup_parents = true,      -- Lookup config files in parent directories
          }
          require("config-local").setup(opts)
        '';
    };
  };
}
