local M = {}

function M.in_visual_mode()
    return string.sub(string.lower(vim.api.nvim_get_mode()["mode"]), 1, 1) == "v"
end

local function find_first(text, patterns, pos)
    for _, pattern in pairs(patterns) do
        local start, stop = string.find(text, pattern, pos)
        if start ~= nil then
            return start, stop
        end
    end
    return nil
end

function M.get_list_item_info(line)
    if line == nil then
        line = vim.api.nvim_win_get_cursor(0)[1] - 1
    end

    -- Note: there's some hacky math here since we're converting between 1 and
    -- 0-based indexing, but there are tests for it
    --
    local text = vim.api.nvim_buf_get_lines(0, line, line + 1, true)[1] or ""
    -- skip over initial whitespace
    local _, startpos = string.find(text, " *")
    if startpos == nil then return nil end

    local _, endpos = find_first(text, {"^[*+-]", "^%d+%."}, startpos + 1)
    if endpos == nil then return nil end

    local _, text_start = find_first(text, {"^ ", "^$"}, endpos + 1)
    if text_start == nil then return nil end

    local checkbox = nil
    local cb_start, cb_end = string.find(text, "^%[[ xX]%]", text_start + 1)
    if cb_start ~= nil then
        _, text_start = find_first(text, {"^ ", "^$"}, cb_end + 1)
        if text_start == nil then return nil end
        checkbox = {
            start = cb_start-1,
            stop = cb_end-1,
            checked = string.lower(string.sub(text, cb_start+1, cb_start+1)) == "x",
        }

    end

    return {
        marker = string.sub(text, startpos+1, endpos),
        start = startpos,
        text_start = text_start,
        checkbox = checkbox,
    }
end

function M.auto_insert_text(line)
    local info = M.get_list_item_info(line)
    if info == nil then return nil end

    local text = string.rep(" ", info.start) .. info.marker
    if info.checkbox then
        return text .. " [ ] "
    else
        return text .. " "
    end
end

function M.backspace_count(line, pos)
    local info = M.get_list_item_info(line)
    if info == nil then return nil end

    local text = string.rep(" ", info.start) .. info.marker
    if info.checkbox then
        return text .. " [ ] "
    else
        return text .. " "
    end
end

return M
