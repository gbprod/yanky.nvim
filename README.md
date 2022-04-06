# 🖇️ yanky.nvim

**This plugin is under development, use at your own risk**

![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)
[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/gbprod/yanky.nvim/Integration?style=for-the-badge)](https://github.com/gbprod/yanky.nvim/actions/workflows/integration.yml)

The aim of `yanky.nvim` is to improve yank and put behavior in Neovim.

French slogan:

> "Vas-y Yanky, c'est bon !" - Yanky Vincent

Or in English:

> "Yanky-ki-yay, motherf\*cker" - John McYanky

## ✨ Features

- [Yank-ring](#-yank-ring)
- [Hightlight put and yanked text](#-hightlight-put-and-yanked-text)
- [Perserve cursor position on yank](#-preserve-cursor-position-on-yank)

## ⚡️ Requirements

Requires neovim > 0.6.0.

## Usage

## 📦 Installation

Install the plugin with your preferred package manager:

### [packer](https://github.com/wbthomason/packer.nvim)

```lua
-- Lua
use({
  "gbprod/yanky.nvim",
  config = function()
    require("yanky").setup({
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    })
  end
})
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
" Vim Script
Plug 'gbprod/yanky.nvim'
lua << EOF
  require("yanky").setup({
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  })
EOF
```

## ⚙️ Configuration

Yanky comes with the following defaults:

```lua
{
  ring = {
    history_length = 10,
    storage = "shada",
    sync_with_numbered_registers = true,
  },
  system_clipboard = {
    sync_with_ring = true,
  },
  highlight = {
    on_put = true,
    on_yank = true,
    timer = 500,
  },
  preserve_cursor_position = {
    enabled = true,
  },
}
```

### ⌨️ Mappings

This plugin contains no default mappings and will have no effect until you add your own maps to it.
You should at least set those keymaps:

```lua
vim.api.nvim_set_keymap("n", "p", "<Plug>(YankyPutAfter)", {})
vim.api.nvim_set_keymap("n", "P", "<Plug>(YankyPutBefore)", {})
vim.api.nvim_set_keymap("x", "p", "<Plug>(YankyPutAfter)", {})
vim.api.nvim_set_keymap("x", "P", "<Plug>(YankyPutBefore)", {})
vim.api.nvim_set_keymap("n", "gp", "<Plug>(YankyGPutAfter)", {})
vim.api.nvim_set_keymap("n", "gP", "<Plug>(YankyGPutBefore)", {})
vim.api.nvim_set_keymap("x", "gp", "<Plug>(YankyGPutAfter)", {})
vim.api.nvim_set_keymap("x", "gP", "<Plug>(YankyGPutBefore)", {})
```

Some features requires specific mappings, refer to feature documentation section.

## 🍃 Yank-ring

Yank-ring allows cycling throught yank history when putting text (like the Emacs "kill-ring" feature).
Yanky automatically maintain a history of yanks that you can choose between when pasting.

### ⌨️ Mappings

```lua
vim.api.nvim_set_keymap("n", "<c-n>", "<Plug>(YankyCycleForward)", {})
vim.api.nvim_set_keymap("n", "<c-p>", "<Plug>(YankyCycleBackward)", {})
```

With these mappings, after performing a paste, you can cycle through the history by hitting `<c-n>` and `<c-p>`.
Any modifications done after pasting will cancel the possibility to cycle.

Note that the swap operations above will only affect the current paste and the history will be unchanged.

### ⚙️ Configuration

```lua
require("yanky").setup({
  ring = {
    history_length = 10,
    storage = "shada",
    sync_with_numbered_registers = true,
  },
  system_clipboard = {
    sync_with_ring = true,
  },
})
```

#### `ring.history_length`

Default : `10`

Define the number of yanked items that will be saved and used for ring.

#### `ring.storage`

Default : `shada`

Available : `shada` or `memory`

Define the storage mode for ring values.

Using `shada`, this will save pesistantly using Neovim ShaDa feature. This means
that history will be persisted between each session of Neovim.

You can also use this feature to sync the yank history across multiple running instances
of Neovim by updating shada file. If you execute `:wshada` in the first instance
and then `:rshada` in the second instance, the second instance will be synced with
the yank history in the first instance.

Using `memory`, each Neovim instance will have his own history and il will be
lost between sessions.

### `ring.sync_with_numbered_registers`

Default : `true`

History can also be synchronized with numbered registers. Every time the yank history changes the numbered registers 1 - 9.
will be updated to sync with the first 9 entries in the yank history. See [here](http://vimcasts.org/blog/2013/11/registers-the-good-the-bad-and-the-ugly-parts/)
for an explanation of why we would want do do this.

### `system_clipboard.sync_with_ring`

Default: `true`

Yanky can automatically adds to ring history yanks that occurs outside of Neovim.
This works regardless to your `&clipboard` setting.

This means, if `&clipboard` is set to `unnamed` and/or `unnamedplus`, if you yank something outside of Neovim, you can put it immediatly using `p` and it will be added to your yank ring.

If `&clipboard` is empty, if you yank something outside of Neovim, this will be the first value you'll have when cycling through the ring. Basicly, you can do `p` and then `<c-p>` to paste yanked text.

## 💡 Hightlight put and yanked text

This will give you a visual feedback on put and yank text
by highlighting this.

### Configuration

```lua
require("yanky").setup({
  highlight = {
    on_put = true,
    on_yank = true,
    timer = 500,
  },
})
```

You can override `YankyPut` highlight to change colors.

#### `highlight.on_put`

Default : `true`

Define if highlight put text feature is enabled.

#### `highlight.on_yank`

Default : `true`

Define if highlight yanked text feature is enabled.

#### `ring.timeout`

Default : `500`

Define the duration of highlight.

## ⏹️ Preserve cursor position on yank

By default in Neovim, when yanking text, cursor moves to the start of the yanked text. Could be annoying especially when yanking a large text object such as a paragraph or a large text object.

With this feature, yank will function exactly the same as previously with the one difference being that the cursor position will not change after performing a yank.

### ⌨️ Mappings

```lua
vim.api.nvim_set_keymap("n", "y", "<Plug>(YankyYank)", {})
vim.api.nvim_set_keymap("x", "y", "<Plug>(YankyYank)", {})
```

### ⚙️ Configuration

```lua
require("yanky").setup({
  preserve_cursor_position = {
    enabled = true,
  },
})
```

#### `preserve_cursor_position.enable`

Default : `true`

Define if cursor position should be preserved on yank. This works only if mappings has been defined.

## 🤝 Credits

This plugin is mostly a lua version of [svermeulen/vim-yoink](https://github.com/svermeulen/vim-yoink) awesome plugin.

Other inspiration :

- [bfredl/nvim-miniyank](https://github.com/bfredl/nvim-miniyank)
- [maxbrunsfeld/vim-yankstack](https://github.com/maxbrunsfeld/vim-yankstack)
- [svermeulen/vim-easyclip](https://github.com/svermeulen/vim-easyclip)
- [bkoropoff/yankee.vim](https://github.com/bkoropoff/yankee.vim)
- [svban/YankAssassin.vim](https://github.com/svban/YankAssassin.vim)

Thanks to [m00qek lua plugin template](https://github.com/m00qek/plugin-template.nvim).
