return {
    "mhartington/formatter.nvim",
    cmd = { "Format", "FormatWrite" },
    lazy = false,
    config = function(_, opts)
        local fmt = require("formatter")
        local fmts = require("formatter.defaults")
        local fs = require("formatter.filetypes")
        local fmtuser = require("user.util.format")

        -- Adjust goline which has bugs on tags
        opts = {
            logging = true,
            log_level = vim.log.levels.INFO,

            tempfile_dir = vim.uv.os_tmpdir(),

            filetype = {
                typescriptreact = { fmts.prettier },
                javascriptreact = { fmts.prettier },
                javascript = { fmts.prettier },
                typescript = { fmts.prettier },
                json = { fmts.prettier },
                jsonc = { fmts.prettier },
                html = { fmts.prettier },
                css = { fmts.prettier },
                scss = { fmts.prettier },
                graphql = { fmts.prettier },
                markdown = { fmts.prettier },
                vue = { fmts.prettier },
                astro = { fmts.prettier },
                yaml = { fmts.prettier },
                go = {
                    fs.go.gofmt,
                    fs.go.goimports,
                    function()
                        return { exe = "golines", args = { "--no-reformat-tags" } }
                    end,
                },
                sql = {
                    fmtuser.sql_format,
                },
                starlark = { fs.python.black, fs.python.isort },
                python = { fs.python.black, fs.python.isort },
                cpp = { fs.cpp.clangformat },
                sh = { fs.sh.shfmt },
                lua = { fs.lua.stylua },
                nix = { fs.nix.nixfmt },
                rust = {
                    function()
                        return {
                            exe = "rustfmt",
                            stdin = true,
                        }
                    end,
                },
                ["*"] = {
                    -- "formatter.filetypes.any" defines default configurations for any
                    -- filetype
                    fs.any.remove_trailing_whitespace,
                },
            },
        }

        fmt.setup(opts)

        require("user.util.format-on-save").enable_format_on_save()
    end,
}
