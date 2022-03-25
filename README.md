# 🖇️ yanky.nvim

**This plugin is under development, use at your own risk**

![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)
[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/gbprod/yanky.nvim/Integration?style=for-the-badge)](https://github.com/gbprod/yanky.nvim/actions/workflows/integration.yml)

The aim of `yanky.nvim` is to improve yank and put behavior in Neovim.

French slogan:

> "Vas-y Yanky, c'est bon !" - Yanky Vincent

Or in English:

> "Yanky-ki-yay, motherf\*cker" - John McYanky

## Features

Testing:

- Allows cycling throught registers when pasting (like the Emacs "kill-ring" feature)
- Hightlight put text
- Persistant history between Neovim sessions using shada
- Automaticly record yanks that occur outside of Neovim by checking system clipboard on focus.
- Synchronize yank history with numbered registers
- yank preserve cursor

Incoming:

- Highlight yanked text
- Allows to change register type.
- `vim.ui.select` integration

## Usage

Requires neovim > 0.6.0.

Using [https://github.com/wbthomason/packer.nvim](packer):

```lua
use({
  "gbprod/yanky.nvim",
  config = function()
    require("yanky").setup()
  end
})
```

## Yank ring

It contains no default mappings and will have no effect until you add your own maps to it.

```lua
vim.api.nvim_set_keymap("n", "p", "<Plug>(YankyPutAfter)", {})
vim.api.nvim_set_keymap("n", "P", "<Plug>(YankyPutBefore)", {})
vim.api.nvim_set_keymap("x", "p", "<Plug>(YankyPutAfter)", {})
vim.api.nvim_set_keymap("x", "P", "<Plug>(YankyPutBefore)", {})

vim.api.nvim_set_keymap("n", "gp", "<Plug>(YankyGPutAfter)", {})
vim.api.nvim_set_keymap("n", "gP", "<Plug>(YankyGPutBefore)", {})
vim.api.nvim_set_keymap("x", "gp", "<Plug>(YankyGPutAfter)", {})
vim.api.nvim_set_keymap("x", "gP", "<Plug>(YankyGPutBefore)", {})

vim.api.nvim_set_keymap("n", "<c-n>", "<Plug>(YankyCycleForward)", {})
vim.api.nvim_set_keymap("n", "<c-p>", "<Plug>(YankyCycleBackward)", {})
```

With these mappings, after performing a paste, you can cycle through the history by hitting `<c-n>` and `<c-p>`.
Any modifications done after pasting will cancel the possibility to cycle.

Note that the swap operations above will only affect the current paste and the history will be unchanged.

### Configuration

```lua
require("yanky").setup({
  ring = {
    history_length = 10,
    storage = "shada",
  }
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

## Highlight put text

This is an experimental feature, it may disapear if not useful. This is disabled
by default.

Like `on_yank` Neovim feature, this will give you a visual feedback on put text
by highlighting this.

### Configuration

```lua
require("yanky").setup({
  highlight = {
    enabled = true,
    timeout = 500,
  }
})
```

You can override `YankyPut` highlight to change colors.

#### `highlight.enabled`

Default : `true`

Define if highlight put text feature is enabled.

#### `ring.timeout`

Default : `500`

Define the duration of highlight.

## Credits

This plugin is mostly a lua version of [svermeulen/vim-yoink](https://github.com/svermeulen/vim-yoink) awesome plugin.

Other inspiration :

- [bfredl/nvim-miniyank](https://github.com/bfredl/nvim-miniyank)
- [maxbrunsfeld/vim-yankstack](https://github.com/maxbrunsfeld/vim-yankstack)
- [svermeulen/vim-easyclip](https://github.com/svermeulen/vim-easyclip)
- [bkoropoff/yankee.vim](https://github.com/bkoropoff/yankee.vim)

Thanks to [m00qek lua plugin template](https://github.com/m00qek/plugin-template.nvim).
