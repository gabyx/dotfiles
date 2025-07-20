local function current_file()
    local info = debug.getinfo(1, "S")
    return info.source:sub(2)
end

print("Setup from ", current_file())
