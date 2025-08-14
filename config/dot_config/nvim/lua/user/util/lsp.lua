local M = {}

-- Define Nixd options table.
M._define_nixd_options = function()
    local paths = require("user.util.paths")
    local p = paths.get_nixos_flake_url()

    if p ~= nil then
        return {
            nixos = {
                expr = string.format('(builtins.getFlake "%s").nixosConfiguration.desktop.options', p),
            },

            ["home-manager"] = {
                expr = string.format(
                    '(builtins.getFlake "%s").nixosConfigurations.desktop.options.home-manager.users.type.getSubOptions []',
                    p
                ),
            },
        }
    else
        return {}
    end
end

-- Define Nixd settings.
M.define_nixd_settings = function()
    return {
        formatting = { command = "nixfmt" },

        nixpkgs = {
            expr = "import <nixpkgs> { }",
        },

        options = M._define_nixd_options(),
    }
end

return M
