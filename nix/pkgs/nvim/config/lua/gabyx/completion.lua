local M = {}

---@type function?, function?
local icon_provider, hl_provider

function M.get_kind_icon(CTX)
    -- Evaluate icon provider
    if not icon_provider then
        local _, mini_icons = pcall(require, "mini.icons")
        if _G.MiniIcons then
            icon_provider = function(ctx)
                local is_specific_color = ctx.kind_hl and ctx.kind_hl:match("^HexColor") ~= nil
                if ctx.item.source_name == "LSP" then
                    local icon, hl = mini_icons.get("lsp", ctx.kind or "")
                    if icon then
                        ctx.kind_icon = icon
                        if not is_specific_color then
                            ctx.kind_hl = hl
                        end
                    end
                elseif ctx.item.source_name == "Path" then
                    ctx.kind_icon, ctx.kind_hl =
                        mini_icons.get(ctx.kind == "Folder" and "directory" or "file", ctx.label)
                elseif ctx.item.source_name == "Snippets" then
                    ctx.kind_icon, ctx.kind_hl = mini_icons.get("lsp", "snippet")
                end
            end
        end

        if not icon_provider then
            local lspkind_avail, lspkind = pcall(require, "lspkind")
            if lspkind_avail then
                icon_provider = function(ctx)
                    if ctx.item.source_name == "LSP" then
                        local icon = lspkind.symbol_map[ctx.kind]
                        if icon then
                            ctx.kind_icon = icon
                        end
                    elseif ctx.item.source_name == "Snippets" then
                        local icon = lspkind.symbol_map["Snippet"]
                        if icon then
                            ctx.kind_icon = icon
                        end
                    end
                end
            end
        end
        if not icon_provider then
            icon_provider = function() end
        end
    end
    -- Evaluate highlight provider
    if not hl_provider then
        local highlight_colors_avail, highlight_colors = pcall(require, "nvim-highlight-colors")
        if highlight_colors_avail then
            local kinds
            hl_provider = function(ctx)
                if not kinds then
                    kinds = require("blink.cmp.types").CompletionItemKind
                end
                if ctx.item.kind == kinds.Color then
                    local doc = vim.tbl_get(ctx, "item", "documentation")
                    if doc then
                        local color_item = highlight_colors_avail
                            and highlight_colors.format(doc, { kind = kinds[kinds.Color] })
                        if color_item and color_item.abbr_hl_group then
                            if color_item.abbr then
                                ctx.kind_icon = color_item.abbr
                            end
                            ctx.kind_hl = color_item.abbr_hl_group
                        end
                    end
                end
            end
        end
        if not hl_provider then
            hl_provider = function() end
        end
    end
    -- Call resolved providers
    icon_provider(CTX)
    hl_provider(CTX)
    -- Return text and highlight information
    return { text = CTX.kind_icon .. CTX.icon_gap, highlight = CTX.kind_hl }
end
