# yanky.nvim

[![Integration](https://github.com/gbprod/yanky.nvim/actions/workflows/integration.yml/badge.svg)](https://github.com/gbprod/yanky.nvim/actions/workflows/integration.yml)

The aim of `yanky.nvim` is to improve yank behavior in Neovim.

Slogan: "Vas-y Yanky, c'est bon !" - Yanky Vincent

## Features

- Allows cycling throught registers when pasting (like the Emacs "kill-ring" feature).
- Persist yank history across sessions of Neovim.
- Automaticly record yanks that occur outside of Neovim by checking system clipboard on focus.

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

## Credits

This plugin is mostly a lua version of [svermeulen/vim-yoink](https://github.com/svermeulen/vim-yoink) awesome plugin.

Other inspiration :

- [bfredl/nvim-miniyank](https://github.com/bfredl/nvim-miniyank)
- [maxbrunsfeld/vim-yankstack](https://github.com/maxbrunsfeld/vim-yankstack)
- [svermeulen/vim-easyclip](https://github.com/svermeulen/vim-easyclip)

Thanks to [m00qek lua plugin template](https://github.com/m00qek/plugin-template.nvim).
