# yanky.nvim

**This plugin is under development, use at your own risk**

[![Integration](https://github.com/gbprod/yanky.nvim/actions/workflows/integration.yml/badge.svg)](https://github.com/gbprod/yanky.nvim/actions/workflows/integration.yml)

The aim of `yanky.nvim` is to improve yank and paste behavior in Neovim.

French slogan:

> "Vas-y Yanky, c'est bon !" - Yanky Vincent

Or in English:

> "Yanky-ki-yay, motherf\*cker" - John McYanky

## Features

Testing:

- Allows cycling throught registers when pasting (like the Emacs "kill-ring" feature)

Incoming:

- Hightlight pasted text
- yank preserve cursor
- Allows to change register type.
- Automaticly record yanks that occur outside of Neovim by checking system clipboard on focus.
- Telescope integration

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
vim.api.nvim_set_keymap("n", "<c-n>", "<Plug>(YankyCycleForward)", {})
vim.api.nvim_set_keymap("n", "<c-p>", "<Plug>(YankyCycleBackward)", {})
```

With these mappings, after performing a paste, you can cycle through the history by hitting `<c-n>` and `<c-p>`.
Any modifications done after pasting will cancel the possibility to cycle.

Note that the swap operations above will only affect the current paste and the history will be unchanged.

## Credits

This plugin is mostly a lua version of [svermeulen/vim-yoink](https://github.com/svermeulen/vim-yoink) awesome plugin.

Other inspiration :

- [bfredl/nvim-miniyank](https://github.com/bfredl/nvim-miniyank)
- [maxbrunsfeld/vim-yankstack](https://github.com/maxbrunsfeld/vim-yankstack)
- [svermeulen/vim-easyclip](https://github.com/svermeulen/vim-easyclip)
- [bkoropoff/yankee.vim](https://github.com/bkoropoff/yankee.vim)

Thanks to [m00qek lua plugin template](https://github.com/m00qek/plugin-template.nvim).
