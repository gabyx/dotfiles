{ ... }:
{
  vim.ui = {
    noice = {
      enable = true;

      setupOpts = {
        routes = [
          {
            filter = {
              event = "msg_show";
              kind = [
                ""
                "echo"
                "echomsg"
                "lua_print"
                "list_cmd"
              ];
            };
            opts = {
              merge = false;
              replace = false;
              title = "Messages";
            };
            view = "notify";
          }
        ];

        presets = {
          bottom_search = true; # use a classic bottom cmdline for search
          command_palette = true; # position the cmdline and popupmenu together
          long_message_to_split = true; # long messages will be sent to a split
          inc_rename = true; # enables an input dialog for inc-rename.nvim
          lsp_doc_border = true; # add a border to hover docs and signature help
        };
      };

    };

    borders = {
      enable = true;

      globalStyle = "rounded";
    };

    illuminate.enable = true;
  };
}
