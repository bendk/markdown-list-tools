local M = { }
local opts = {
    -- Which keys to remap for markdown files.  Set to `false` to disable all remapping.
    remap = {
        -- Remap <enter> in insert mode to auto-insert list items
        enter = true,
        -- Remap `o` in normal mode to auto-insert list items
        o = true,
        -- Remap `O` in normal mode to auto-insert list items
        O = true,
    },
}
local util = require("markdown-list-tools.util")

local function feedkeys_from_list_item_info(list_item_info)
    if list_item_info ~= nil then
        vim.api.nvim_feedkeys(list_item_info.marker .. " ", "n", false)
        if list_item_info.checkbox ~= nil then 
            vim.api.nvim_feedkeys("[ ] ", "n", false)
        end
    end
end

function M.enter()
    local list_item_info = util.get_list_item_info(line)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<return>", true, true, true), "n", false)
    feedkeys_from_list_item_info(list_item_info)
end

function M.o()
    local list_item_info = util.get_list_item_info(line)
    vim.api.nvim_feedkeys("o", "n", false)
    feedkeys_from_list_item_info(list_item_info)
end

function M.O()
    local list_item_info = util.get_list_item_info(line)
    vim.api.nvim_feedkeys("O", "n", false)
    feedkeys_from_list_item_info(list_item_info)
end

function M.toggle_checkbox()
    vim.go.operatorfunc = "v:lua.require'markdown-list-tools'.toggle_checkbox_callback"
    if util.in_visual_mode() then
        vim.cmd("normal! g@")
    else
        vim.cmd("normal! g@l")
    end
end

function M.toggle_checkbox_callback(motion)
    for line, _ in pairs(vim.region(0, "'[", "']", "l", false)) do
        local list_item_info = util.get_list_item_info(line)
        if list_item_info then
            if list_item_info.checkbox then
                local cb = list_item_info.checkbox
                if list_item_info.checkbox.checked then
                    vim.api.nvim_buf_set_text(0, line, cb.start + 1, line, cb.stop, {" "})
                else
                    vim.api.nvim_buf_set_text(0, line, cb.start + 1, line, cb.stop, {"x"})
                end
            end
        end
    end
end

function M.setup(setup_opts)
    opts = vim.tbl_deep_extend("force", opts, setup_opts or {})
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
          if opts.remap.enter then
              vim.api.nvim_buf_set_keymap(0, "i", "<return>", "<cmd>lua require('markdown-list-tools').enter()<cr>", {})
          end
          if opts.remap.o then
              vim.api.nvim_buf_set_keymap(0, "n", "o", "<cmd>lua require('markdown-list-tools').o()<cr>", {})
          end
          if opts.remap.O then
              vim.api.nvim_buf_set_keymap(0, "n", "O", "<cmd>lua require('markdown-list-tools').O()<cr>", {})
          end
      end
    })
end

return M
