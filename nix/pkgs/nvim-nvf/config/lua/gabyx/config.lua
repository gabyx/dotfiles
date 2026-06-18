local mid_mapping = false

---@class Autocmd: vim.api.keyset.create_autocmd
---@field event string|string[] Event(s) that will trigger the handler

---@class LargeBugCfg
---@field enabled (boolean|fun(bufnr: integer, config: LargeBugCfg):boolean|LargeBugCfg?)? whether to enable large file detection
---@field notify boolean? whether or not to display a notification when a large file is detected
---@field size integer|false? the number of bytes in a file or false to disable check
---@field lines integer|false? the number of lines in a file or false to disable check
---@field line_length integer|false? the average line length in a file or false to disable check buffer settings.

---@class gabyx.Settings
---
---table for defining the size of the max file for all features, above these limits we disable features like treesitter.
---value can also be `false` to disable large buffer detection.
---Example:
---
---```lua
---large_buf = {
---  size = 1024 * 100,
---  lines = 10000
---},
---```
---@field large_buf_opts LargeBugCfg|false?
---
---Configuration of auto commands
---The key into the table is the group name for the auto commands (`:h augroup`) and the value
---is a list of autocmd tables where `event` key is the event(s) that trigger the auto command
---and the rest are auto command options (`:h nvim_create_autocmd`)
---Example:
---
---```lua
---autocmds = {
---  -- first key is the `augroup` (:h augroup)
---  highlighturl = {
---    -- list of auto commands to set
---    {
---      -- events to trigger
---      event = { "VimEnter", "FileType", "BufEnter", "WinEnter" },
---      -- the rest of the autocmd options (:h nvim_create_autocmd)
---      desc = "URL Highlighting",
---      callback = function() require("astrocore").set_url_match() end
---    }
---  }
---}
---```
---@field autocmds table<string,Autocmd[]|false>?
---
---Configuration of vim `on_key` functions.
---The key into the table is the namespace of the function and the value is a list like table of `on_key` functions
---Example:
---
---```lua
---on_keys = {
---  -- first key is the namespace
---  auto_hlsearch = {
---    -- list of functions to execute on key press (:h vim.on_key)
---    function(char) -- example automatically disables `hlsearch` when not actively searching
---      if vim.fn.mode() == "n" then
---        local new_hlsearch = vim.tbl_contains({ "<CR>", "n", "N", "*", "#", "?", "/" }, vim.fn.keytrans(char))
---        if vim.opt.hlsearch:get() ~= new_hlsearch then vim.opt.hlsearch = new_hlsearch end
---      end
---    end,
---  },
---},
---```
---@field on_keys table<string,fun(key:string)[]|false>?
---
---Configuration of `vim` options (`vim.<first_key>.<second_key> = value`)
---The first key into the table is the type of option and the second key is the setting
---Example:
---
---```lua
---options = {
---  -- first key is the type of option
---  opt = { -- (`vim.opt`)
---    relativenumber = true, -- sets `vim.opt.relativenumber`
---    signcolumn = "auto", -- sets `vim.opt.signcolumn`
---  },
---  g = { -- (`vim.g`)
---    -- set global `vim.g.<key>` settings here
---  }
---}
---```
---@field options table<string,table<string,any>>?

local function get_default_vim_options()
    local opt = {}
    local get_icon = require("gabyxui").get_icon

    opt.backspace = vim.list_extend(vim.opt.backspace:get(), { "nostop" }) -- don't stop backspace at insert
    opt.breakindent = true -- wrap indent to match  line start
    opt.clipboard = "unnamedplus" -- connection to the system clipboard
    opt.cmdheight = 0 -- hide command line unless needed
    opt.completeopt = { "menu", "menuone", "noselect" } -- Options for insert mode completion
    opt.confirm = true -- raise a dialog asking if you wish to save the current file(s)
    opt.copyindent = true -- copy the previous indentation on autoindenting
    opt.cursorline = true -- highlight the text line of the cursor
    opt.diffopt = vim.list_extend(vim.opt.diffopt:get(), { "algorithm:histogram", "linematch:60" }) -- enable linematch diff algorithm
    opt.expandtab = true -- enable the use of space in tab
    opt.fillchars = {
        eob = " ",
        foldopen = get_icon("FoldOpened"), -- fold open icon
        foldclose = get_icon("FoldClosed"), -- fold close icon
        foldsep = get_icon("FoldSeparator"), -- fold separator
        foldinner = get_icon("FoldSeparator"), -- nested fold separator
    } -- disable `~` on nonexistent lines
    opt.ignorecase = true -- case insensitive searching
    opt.infercase = true -- infer cases in keyword completion
    opt.jumpoptions = {} -- apply no jumpoptions on startup
    opt.laststatus = 3 -- global statusline
    opt.linebreak = true -- wrap lines at 'breakat'
    opt.mouse = "a" -- enable mouse support
    opt.number = true -- show numberline
    opt.preserveindent = true -- preserve indent structure as much as possible
    opt.pumheight = 10 -- height of the pop up menu
    opt.relativenumber = true -- show relative numberline
    opt.shiftround = true -- round indentation with `>`/`<` to shiftwidth
    opt.shiftwidth = 0 -- number of space inserted for indentation; when zero the 'tabstop' value will be used
    opt.shortmess = vim.tbl_deep_extend("force", vim.opt.shortmess:get(), { s = true, I = true, c = true, C = true }) -- disable search count wrap, startup messages, and completion messages
    opt.showmode = false -- disable showing modes in command line
    opt.showtabline = 2 -- always display tabline
    opt.signcolumn = "yes" -- always show the sign column
    opt.smartcase = true -- case sensitive searching
    opt.splitbelow = true -- splitting a new window below the current one
    opt.splitright = true -- splitting a new window at the right of the current one
    opt.tabclose = "uselast" -- go to last used tab when closing the current tab
    opt.tabstop = 2 -- number of space in a tab
    opt.termguicolors = true -- enable 24-bit RGB color in the TUI
    opt.timeoutlen = 500 -- shorten key timeout length a little bit for which-key
    opt.title = true -- set terminal title to the filename and path
    opt.undofile = true -- enable persistent undo
    opt.updatetime = 300 -- length of time to wait before triggering the plugin
    opt.virtualedit = "block" -- allow going past end of line in visual block mode
    opt.winborder = "rounded" -- set default winborder to rounded
    opt.wrap = false -- disable wrapping of lines longer than the width of window
    opt.writebackup = false -- disable making a backup before overwriting a file

    local g = {}
    g.markdown_recommended_style = 0

    -- initialize buffer list
    if not vim.t.bufs then
        vim.t.bufs = vim.api.nvim_list_bufs()
    end

    return { opt = opt, g = g, t = { bufs = vim.t.bufs } }
end

---@type gabyx.Settings
local M = {
    options = vim.tbl_deep_extend("force", get_default_vim_options(), {
        opt = { -- vim.opt.<key>
            relativenumber = true, -- sets vim.opt.relativenumber
            number = true, -- sets vim.opt.number
            spell = false, -- sets vim.opt.spell
            signcolumn = "auto", -- sets vim.opt.signcolumn to auto
            wrap = false, -- sets vim.opt.wrap

            -- Treesitter folding
            foldmethod = "expr",
            foldexpr = "nvim_treesitter#foldexpr()",
            -- Whitespace Characters
            listchars = "tab:▷ ,trail:·,extends:◣,precedes:◢,nbsp:○",
            list = true,
            -- Auto-reload files when modified externally
            -- https://unix.stackexchange.com/a/383044
            autoread = true,
            -- Do not conceal anything in files
            -- (markdown code blocks as example).
            conceallevel = 0,

            diffopt = "internal,anchor,filler,closeoff,linematch:40,algorithm:histogram,linematch:60",
        },
        g = { -- vim.g.<key>
        },
    }),

    large_buf_opts = {
        enabled = true,
        size = 1000 * 1024 * 1024,
        lines = 500000,
        line_length = nil,
        notify = true,
    },

    autocmds = {
        bufferline = {
            {
                event = { "BufAdd", "BufEnter", "TabNewEntered" },
                desc = "Update buffers when adding new buffers",
                callback = function(args)
                    local buf_utils = require("gabyx.buffer")
                    if not vim.t.bufs then
                        vim.t.bufs = {}
                    end
                    if not buf_utils.is_valid(args.buf) then
                        return
                    end
                    if args.buf ~= buf_utils.current_buf then
                        buf_utils.last_buf = buf_utils.is_valid(buf_utils.current_buf) and buf_utils.current_buf or nil
                        buf_utils.current_buf = args.buf
                    end
                    local bufs = vim.t.bufs
                    if not vim.tbl_contains(bufs, args.buf) then
                        table.insert(bufs, args.buf)
                        vim.t.bufs = bufs
                    end
                    vim.t.bufs = vim.tbl_filter(buf_utils.is_valid, vim.t.bufs)

                    require("gabyx").event("BufsUpdated")
                end,
            },
            {
                event = { "BufDelete", "TermClose" },
                desc = "Update buffers when deleting buffers",
                callback = function(args)
                    local removed

                    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
                        local bufs = vim.t[tab].bufs
                        if bufs then
                            for i, bufnr in ipairs(bufs) do
                                if bufnr == args.buf then
                                    removed = true
                                    table.remove(bufs, i)
                                    vim.t[tab].bufs = bufs
                                    break
                                end
                            end
                        end
                    end

                    vim.t.bufs = vim.tbl_filter(require("gabyx.buffer").is_valid, vim.t.bufs)

                    if removed then
                        require("gabyx").event("BufsUpdated")
                    end

                    vim.cmd.redrawtabline()
                end,
            },
        },
        checktime = {
            {
                event = { "FocusGained", "TermClose", "TermLeave" },
                desc = "Check if buffers changed on editor focus",
                callback = function()
                    if vim.bo.buftype ~= "nofile" then
                        vim.cmd("checktime")
                    end
                end,
            },
        },
        create_dir = {
            {
                event = "BufWritePre",
                desc = "Automatically create parent directories if they don't exist when saving a file",
                callback = function(args)
                    local file = args.match
                    if not require("gabyx.buffer").is_valid(args.buf) or file:match("^%w+:[\\/][\\/]") then
                        return
                    end
                    vim.fn.mkdir(vim.fs.abspath(vim.fs.dirname(vim.uv.fs_realpath(file) or file)), "p")
                end,
            },
        },
        highlightyank = {
            {
                event = "TextYankPost",
                desc = "Highlight yanked text",
                pattern = "*",
                callback = function()
                    vim.hl.on_yank()
                end,
            },
        },
        large_buf_settings = {
            {
                event = "User",
                desc = "Disable certain functionality on very large files",
                pattern = "GabyxLargeBuf",
                callback = function(args)
                    vim.opt_local.list = false -- disable list chars
                    vim.b[args.buf].autoformat = false -- disable autoformat on save
                    vim.b[args.buf].completion = false -- disable completion
                end,
            },
        },
        q_close_windows = {
            {
                event = "BufWinEnter",
                desc = "Make q close help, man, quickfix, dap floats",
                callback = function(args)
                    -- Add cache for buffers that have already had mappings created
                    if not vim.g.q_close_windows then
                        vim.g.q_close_windows = {}
                    end
                    -- If the buffer has been checked already, skip
                    if vim.g.q_close_windows[args.buf] then
                        return
                    end
                    -- Mark the buffer as checked
                    vim.g.q_close_windows[args.buf] = true
                    -- Check to see if `q` is already mapped to the buffer (avoids overwriting)
                    for _, map in ipairs(vim.api.nvim_buf_get_keymap(args.buf, "n")) do
                        if map.lhs == "q" then
                            return
                        end
                    end
                    -- If there is no q mapping already and the buftype is a non-real file, create one
                    if vim.tbl_contains({ "help", "nofile", "quickfix" }, vim.bo[args.buf].buftype) then
                        vim.keymap.set("n", "q", "<Cmd>close<CR>", {
                            desc = "Close window",
                            buffer = args.buf,
                            silent = true,
                            nowait = true,
                        })
                    end
                end,
            },
            {
                event = "BufDelete",
                desc = "Clean up q_close_windows cache",
                callback = function(args)
                    if vim.g.q_close_windows then
                        vim.g.q_close_windows[args.buf] = nil
                    end
                end,
            },
            restore_cursor = {
                {
                    event = "BufReadPost",
                    desc = "Restore last cursor position when opening a file",
                    callback = function(args)
                        local buf = args.buf
                        if vim.b[buf].last_loc_restored or vim.tbl_contains({ "gitcommit" }, vim.bo[buf].filetype) then
                            return
                        end
                        vim.b[buf].last_loc_restored = true
                        local mark = vim.api.nvim_buf_get_mark(buf, '"')
                        if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(buf) then
                            pcall(vim.api.nvim_win_set_cursor, 0, mark)
                        end
                    end,
                },
            },
            unlist_quickfix = {
                {
                    event = "FileType",
                    desc = "Unlist quickfix buffers",
                    pattern = "qf",
                    callback = function()
                        vim.opt_local.buflisted = false
                    end,
                },
            },
        },
    },

    on_keys = {
        auto_hlsearch = {
            -- It's a smart `hlsearch` manager — it automatically turns search highlighting **on/off** based on what you're doing:
            -- - **Normal mode**: only highlights when you press actual search keys (`/`, `?`, `n`, `N`, `*`, `#`, `<CR>`)
            -- - **Replace mode** (`r`): always highlights
            -- - **Command mode** (`:`): highlights only when you run a substitute command (`s/`, `%s/`, `'<,'>s/`) with `incsearch` enabled
            -- - **Anything else**: does nothing (leaves hlsearch as-is)
            -- The `mid_mapping` flag is a debounce guard — it prevents the `on_key` callback from firing recursively/multiple times for a single keypress (since setting `hlsearch` itself can trigger further key processing).
            -- The net effect is: highlighting appears when searching and disappears when you do anything unrelated, without you ever needing to manually `:noh`.
            function(char)
                if mid_mapping then
                    return
                end
                local new_hlsearch
                local mode = vim.api.nvim_get_mode().mode:sub(1, 1)
                if mode == "n" then -- enable highlight search when actively searching in normal mode
                    new_hlsearch = vim.tbl_contains({ "<CR>", "n", "N", "*", "#", "?", "/" }, vim.fn.keytrans(char))
                elseif mode == "r" then -- always enable highlight search in replace mode
                    new_hlsearch = true
                    -- enable highlight search when searching in command mode
                elseif mode == "c" and vim.tbl_contains({ "<CR>" }, vim.fn.keytrans(char)) then
                    local cmd = vim.fn.getcmdline()
                    if (cmd:match("^s") or cmd:match("^%%s") or cmd:match("^'<,'>s")) and vim.o.incsearch then
                        new_hlsearch = true
                    end
                else
                    return
                end
                if vim.o.hlsearch ~= new_hlsearch then
                    vim.opt.hlsearch = new_hlsearch
                end

                mid_mapping = true
                vim.schedule(function()
                    mid_mapping = false
                end)
            end,
        },
    },
}

return M
