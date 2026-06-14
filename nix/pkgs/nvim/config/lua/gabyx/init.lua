local M = {}

--- Serve a notification with a title.
---@param msg string The notification body
---@param type integer|nil The type of the notification (:help vim.log.levels)
---@param opts? table The nvim-notify options to use (:help notify-options)
function M.notify(msg, type, opts)
    vim.schedule(function()
        vim.notify(msg, type, M.extend_tbl({ title = "Gabyx-Nvim" }, opts))
    end)
end

--- Merge extended options with a default table of options
---@param default? table The default table that you want to merge into
---@param opts? table The new options that should be merged with the default table
---@return table extended The extended table
function M.extend_tbl(default, opts)
    opts = opts or {}
    return default and vim.tbl_deep_extend("force", default, opts) or opts
end

--- Trigger an custom user event
---@param event string|vim.api.keyset_exec_autocmds The event pattern or full autocmd options (pattern always prepended with "Custom")
---@param instant? boolean Whether or not to execute instantly or schedule
function M.event(event, instant)
    if type(event) == "string" then
        event = { pattern = event }
    end

    event = M.extend_tbl({ modeline = false }, event)
    event.pattern = "Gabyx" .. event.pattern

    if instant then
        vim.api.nvim_exec_autocmds("User", event)
    else
        vim.schedule(function()
            vim.api.nvim_exec_autocmds("User", event)
        end)
    end
end

--- Sets the large buffer detector.
local function set_large_buffer_detector(self)
    vim.api.nvim_create_autocmd("BufRead", {
        group = vim.api.nvim_create_augroup("large_buf_detector", { clear = true }),
        desc = "Large buffer detection loading a file into a buffer",

        callback = function(args)
            if self.buffer.is_large(args.buf) then
                vim.b[args.buf].large_buf = true

                if self.config.large_buf_opts.notify then
                    self.notify(
                        ("Large file detected `%s`\nSome Neovim features may be **disabled**"):format(
                            vim.fn.fnamemodify(vim.api.nvim_buf_get_name(args.buf), ":p:~:.")
                        )
                    )
                end

                self.event("LargeBuf", true)
            end
        end,
    })
end

--- The setup function.
function M.setup(opts)
    M.config = require("gabyx.config")
    M.config = vim.tbl_deep_extend("force", M.config, opts)

    -- Set missing libraries.
    M.buffer = require("gabyx.buffer")
    M.completion = require("gabyx.completion")
    M.diagnostics = require("gabyx.diagnostics")
    M.format = require("gabyx.format")
    M.quit = require("gabyx.quit")

    --- Apply all options.
    if vim.tbl_get(M.config, "options", "opt", "clipboard") then
        local opt = M.config.options.opt
        local lazy_clipboard = opt.clipboard
        opt.clipboard = nil
        vim.schedule(function() -- defer setting clipboard
            opt.clipboard = lazy_clipboard
            vim.opt.clipboard = opt.clipboard
        end)
    end
    for scope, settings in pairs(M.config.options) do
        for setting, value in pairs(settings) do
            vim[scope][setting] = value
        end
    end

    -- Activate all autocommands.
    set_large_buffer_detector(M)
    for augroup, autocmds in pairs(M.config.autocmds) do
        if autocmds then
            local augroup_id = vim.api.nvim_create_augroup(augroup, { clear = true })
            for _, autocmd in ipairs(autocmds) do
                local event = autocmd.event
                autocmd.event = nil
                autocmd.group = augroup_id
                vim.api.nvim_create_autocmd(event, autocmd)
                autocmd.event = event
            end
        end
    end

    -- Set all `on_keys` functions
    for namespace, funcs in pairs(M.config.on_keys) do
        if funcs then
            local ns = vim.api.nvim_create_namespace(namespace)
            for _, func in ipairs(funcs) do
                vim.on_key(func, ns)
            end
        end
    end
end

return M
