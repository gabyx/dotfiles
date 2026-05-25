{
  config,
  lib,
  ...
}:
{
  vim = {
    additionalRuntimePaths = [
      ./config
    ];

    luaConfigRC.gabyx =
      lib.nvim.dag.entryBefore [ "pluginConfigs" ]
        # Lua
        ''
          gabyxui = require("gabyxui")
          gabyxui.setup({
            icons = ${lib.generators.toLua { } config.gabyx.icons}
          })

          gabyx = require("gabyx")
        '';
  };
}
