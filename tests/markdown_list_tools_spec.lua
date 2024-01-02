local markdown_list_tools = require("markdown-list-tools")
local util = require("markdown-list-tools.util")

describe("utils", function()
    local function get_list_item_info(line_text)
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { line_text })
        return util.get_list_item_info(0)
    end

    it('identifies list items', function()
        assert.are.same(nil, get_list_item_info("Foo"))
        assert.are.same({
            marker = "-",
            start = 0,
            text_start = 2,
        }, get_list_item_info("- "))
        assert.are.same({
            marker = "*",
            start = 3,
            text_start = 5,
        }, get_list_item_info("   * "))
        assert.are.same({
            marker = "+",
            start = 0,
            text_start = 1,
        }, get_list_item_info("+"))
        assert.are.same({
            marker = "-",
            start = 0,
            text_start = 2,
        }, get_list_item_info("- Foo"))
        assert.are.same(nil, get_list_item_info(" -Foo"))
        assert.are.same({
            marker = "88.",
            start = 0,
            text_start = 4,
        }, get_list_item_info("88. Foo"))
        assert.are.same(nil, get_list_item_info(" X "))
    end)
    it('identifies checkboxes', function()
        assert.are.same({
            marker = "-",
            start = 0,
            text_start = 5,
            checkbox = {
                start = 2,
                stop = 4,
                checked = false,
            }
        }, get_list_item_info("- [ ]"))
        assert.are.same({
            marker = "+",
            start = 0,
            text_start = 5,
            checkbox = {
                start = 2,
                stop = 4,
                checked = true,
            }
        }, get_list_item_info("+ [X]"))
        assert.are.same({
            marker = "*",
            start = 2,
            text_start = 7,
            checkbox = {
                start = 4,
                stop = 6,
                checked = true,
            }
        }, get_list_item_info("  * [x]"))
        assert.are.same({
            marker = "+",
            start = 0,
            text_start = 6,
            checkbox = {
                start = 2,
                stop = 4,
                checked = false,
            }
        }, get_list_item_info("+ [ ] Foo"))
    end)
end)

describe("auto-insert", function()
    local function auto_insert_text(line_text)
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { line_text })
        return util.auto_insert_text(0)
    end

    it('auto-inserts list items', function()
        assert.equals("- ", auto_insert_text("- foo"))
        assert.equals("    - ", auto_insert_text("    - foo"))
        assert.equals("- [ ] ", auto_insert_text("- [ ] foo"))
        assert.equals("- [ ] ", auto_insert_text("- [x] foo"))
        assert.equals(nil, auto_insert_text("not-an-item"))
    end)
end)

describe("toggle checkboxes", function()
    local function text_after_toggle_checkbox(line_text)
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { line_text })
        vim.api.nvim_win_set_cursor(0, {1, 0})
        markdown_list_tools.toggle_checkbox()
        return vim.fn.getline(1)
    end

    it('checks/unchecks checkboxes', function()
        assert.equals("- [x]", text_after_toggle_checkbox("- [ ]"))
        assert.equals("- [ ]", text_after_toggle_checkbox("- [x]"))
        assert.equals("    - [x]", text_after_toggle_checkbox("    - [ ]"))
        assert.equals("- [x] Foo", text_after_toggle_checkbox("- [ ] Foo"))
        assert.equals("not-an-item", text_after_toggle_checkbox("not-an-item"))
        assert.equals("- ", text_after_toggle_checkbox("- "))

    end)
end)
