local M = {}

-- Define Nixd options table.
M.define_nixd_options = function()
    local paths = require("user.util.paths")
    local p = paths.get_nixos_flake_url()

    if p ~= nil then
        return {
            nixos = {
                expr = string.format('(builtins.getFlake "%s").nixosConfiguration.desktop.options', p),
            },
        }
    else
        return {}
    end
end

-- Define Nixd settings.
M.define_nixd_settings = function()
    return {
        nixpkgs = {
            expr = "import <nixpkgs> { }",
        },
        formatting = { command = "nixfmt" },
        options = M.define_nixd_options(),
    }
end

return M
