{
  config,
  lib,
  ...
}:
{
  vim = {
    additionalRuntimePaths = [
      ../config
    ];

    luaConfigRC.gabyx =
      lib.nvim.dag.entryBefore [ "pluginConfigs" ]
        # Lua
        ''
          gabyx = require("gabyx")
          gabyx.setup({
            icons = ${lib.generators.toLua { } config.gabyx.icons}
          })
        '';
  };
}
