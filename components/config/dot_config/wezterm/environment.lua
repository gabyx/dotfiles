local wezterm = require("wezterm")
local environment = {}

if wezterm.target_triple:find("darwin") then
    environment.os = "mac"
elseif wezterm.target_triple:find("windows") then
    environment.os = "windows"
else
    environment.os = "linux"
end

return environment
