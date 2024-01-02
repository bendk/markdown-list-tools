# markdown-list-tools

Small nvim plugin to handle Markdown lists, including checkbox lists.

## Features

- Auto-insert list items to continue a list (works with `<enter>` in insert mode and `o` and `O` in normal mode).
- Auto-insert also handles checkboxes (`* [ ] My todo item`)
- Toggle checkboxes on and off

## Installation

`lazy.nvim`:
```lua
lazy.setup(
    {
        dir = "~/src/markdown-list-tools.nvim",
        ft = "markdown",
        config = function()
            require("markdown-list-tools").setup()
        end
    },
)
```

## Configuration

```lua
require("markdown-tools").setup({
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
```

## Keybindings

```lua
-- Toggle state for the current checkbox.  Works in normal and visual mode
vim.keymap.set({ 'n', 'x' }, '<leader>c', require('markdown-tools').checkbox_toggle(), { desc = 'Toggle checkbox' });
```

## Is dot-repeat supported?

Yup.

## Credits

Inspired by:
 - [nvim-markdown](https://github.com/ixru/nvim-markdown).
 - [markdown-togglecheck](https://github.com/nfrid/markdown-togglecheck/tree/main).
