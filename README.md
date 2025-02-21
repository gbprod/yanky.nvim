# 🍃 yanky.nvim

![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/gbprod/yanky.nvim/integration.yml?branch=main&style=for-the-badge)](https://github.com/gbprod/yanky.nvim/actions/workflows/integration.yml)

The aim of `yanky.nvim` is to improve yank and put functionalities for Neovim.

French slogan:

> "Vas-y Yanky, c'est bon !" - Yanky Vincent

Or in English:

> "Yanky-ki-yay, motherf\*cker" - John McYanky

## ✨ Features

- 🖇️ Yank-ring
- 📜 Yank history picker
- 💡 Highlight put and yanked text
- ⤵️ Preserve cursor position on yank
- ⭐ Special put
- ⚓ Text object

## ⚡️ Requirements

Requires neovim > `0.9.0`.

## 📦 Installation

Install the plugin with your preferred package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "gbprod/yanky.nvim",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
}
```

<details>
<summary>More complete setup</summary>

```lua
{
  "gbprod/yanky.nvim",
  dependencies = {
    { "kkharji/sqlite.lua" }
  },
  opts = {
    ring = { storage = "sqlite" },
  },
  keys = {
    { "<leader>p", function() require("telescope").extensions.yank_history.yank_history({ }) end, desc = "Open Yank History" },
    { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
    { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after cursor" },
    { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before cursor" },
    { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after selection" },
    { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before selection" },
    { "<c-p>", "<Plug>(YankyPreviousEntry)", desc = "Select previous entry through yank history" },
    { "<c-n>", "<Plug>(YankyNextEntry)", desc = "Select next entry through yank history" },
    { "]p", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after cursor (linewise)" },
    { "[p", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before cursor (linewise)" },
    { "]P", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after cursor (linewise)" },
    { "[P", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before cursor (linewise)" },
    { ">p", "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Put and indent right" },
    { "<p", "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and indent left" },
    { ">P", "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put before and indent right" },
    { "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)", desc = "Put before and indent left" },
    { "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put after applying a filter" },
    { "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put before applying a filter" },
  },
}
```

</details>

### [packer](https://github.com/wbthomason/packer.nvim)

```lua
-- Lua
use("gbprod/yanky.nvim")
require("yanky").setup({
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
})
```

## ⚙️ Configuration

Yanky comes with the following defaults:

```lua
{
  ring = {
    history_length = 100,
    storage = "shada",
    storage_path = vim.fn.stdpath("data") .. "/databases/yanky.db", -- Only for sqlite storage
    sync_with_numbered_registers = true,
    cancel_event = "update",
    ignore_registers = { "_" },
    update_register_on_cycle = false,
    permanent_wrapper = nil,
  },
  picker = {
    select = {
      action = nil, -- nil to use default put action
    },
    telescope = {
      use_default_mappings = true, -- if default mappings should be used
      mappings = nil, -- nil to use default mappings or no mappings (see `use_default_mappings`)
    },
  },
  system_clipboard = {
    sync_with_ring = true,
    clipboard_register = nil,
  },
  highlight = {
    on_put = true,
    on_yank = true,
    timer = 500,
  },
  preserve_cursor_position = {
    enabled = true,
  },
  textobj = {
   enabled = false,
  },
}
```

### ⌨️ Mappings

**This plugin contains no default mappings and will have no effect until you add your own maps to it.**
You should at least set those keymaps for yank ring usage:

```lua
vim.keymap.set({"n","x"}, "p", "<Plug>(YankyPutAfter)")
vim.keymap.set({"n","x"}, "P", "<Plug>(YankyPutBefore)")
vim.keymap.set({"n","x"}, "gp", "<Plug>(YankyGPutAfter)")
vim.keymap.set({"n","x"}, "gP", "<Plug>(YankyGPutBefore)")

vim.keymap.set("n", "<c-p>", "<Plug>(YankyPreviousEntry)")
vim.keymap.set("n", "<c-n>", "<Plug>(YankyNextEntry)")
```

And those keymaps for `tpope/vim-unimpaired` like usage:

```lua
vim.keymap.set("n", "]p", "<Plug>(YankyPutIndentAfterLinewise)")
vim.keymap.set("n", "[p", "<Plug>(YankyPutIndentBeforeLinewise)")
vim.keymap.set("n", "]P", "<Plug>(YankyPutIndentAfterLinewise)")
vim.keymap.set("n", "[P", "<Plug>(YankyPutIndentBeforeLinewise)")

vim.keymap.set("n", ">p", "<Plug>(YankyPutIndentAfterShiftRight)")
vim.keymap.set("n", "<p", "<Plug>(YankyPutIndentAfterShiftLeft)")
vim.keymap.set("n", ">P", "<Plug>(YankyPutIndentBeforeShiftRight)")
vim.keymap.set("n", "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)")

vim.keymap.set("n", "=p", "<Plug>(YankyPutAfterFilter)")
vim.keymap.set("n", "=P", "<Plug>(YankyPutBeforeFilter)")
```

Some features requires specific mappings, refer to feature documentation section.

## 🖇️ Yank-ring

Yank-ring allows cycling throught yank history when putting text (like the Emacs
"kill-ring" feature). Yanky automatically maintain a history of yanks that you
can choose between when pasting.

### ⌨️ Mappings

```lua
vim.keymap.set("n", "<c-p>", "<Plug>(YankyPreviousEntry)")
vim.keymap.set("n", "<c-n>", "<Plug>(YankyNextEntry)")
```

With these mappings, after performing a paste, you can cycle through the history
by hitting `<c-n>` and `<c-p>`. Any modifications done after pasting will cancel
the possibility to cycle.

Note that the swap operations above will only affect the current paste and the
history will be unchanged.

### ⚙️ Configuration

```lua
require("yanky").setup({
  ring = {
    history_length = 100,
    storage = "shada",
    sync_with_numbered_registers = true,
    cancel_event = "update",
    ignore_registers = { "_" },
    update_register_on_cycle = false,
    permanent_wrapper = nil,
  },
  system_clipboard = {
    sync_with_ring = true,
  },
})
```

#### `ring.history_length`

Default : `100`

Define the number of yanked items that will be saved and used for ring.

#### `ring.storage`

Default : `shada`

Available : `shada`, `sqlite` or `memory`

Define the storage mode for ring values.

Using `shada`, this will save pesistantly using Neovim ShaDa feature. This means
that history will be persisted between each session of Neovim.

You can also use this feature to sync the yank history across multiple running instances
of Neovim by updating shada file. If you execute `:wshada` in the first instance
and then `:rshada` in the second instance, the second instance will be synced with
the yank history in the first instance.

Using `memory`, each Neovim instance will have his own history and il will be
lost between sessions.

If you want to use `sqlite` as storage, you must add [`kkharji/sqlite.lua`](https://github.com/kkharji/sqlite.lua) as dependency:

```lua
use({
  "gbprod/yanky.nvim",
  requires = { "kkharji/sqlite.lua" }
})
```

Sqlite is more reliable than ShaDa but requires more dependencies. You can
change the storage path using `ring.storage_path` option.

### `ring.sync_with_numbered_registers`

Default : `true`

History can also be synchronized with numbered registers. Every time the yank
history changes the numbered registers 1 - 9 will be updated to sync with the
first 9 entries in the yank history. See [here](http://vimcasts.org/blog/2013/11/registers-the-good-the-bad-and-the-ugly-parts/)
for an explanation of why we would want do do this.

### `ring.cancel_event`

Default: `update`

Define the event used to cancel ring activation. `update` will cancel ring on
next buffer update, `move` will cancel ring when moving cursor or content
changed.

### `ring.ignore_registers`

Default: `{ "_" }`

Define registeres to be ignored. By default the black hole register is ignored.

### `system_clipboard.sync_with_ring`

Default: `true`

Yanky can automatically adds to ring history yanks that occurs outside of Neovim.
This works regardless to your `&clipboard` setting.

This means, if `&clipboard` is set to `unnamed` and/or `unnamedplus`, if you yank
something outside of Neovim, you can put it immediatly using `p` and it will be
added to your yank ring.

If `&clipboard` is empty, if you yank something outside of Neovim, this will be
the first value you'll have when cycling through the ring. Basicly, you can do
`p` and then `<c-p>` to paste yanked text.

Note that `clipboard == unnamed` uses the primary selection of the system (see
`:h clipbard` for more details) which is updated on selection, not on copy/yank.
Also note that the syncing happens when neovim gains focus.

### `system_clipboard.clipboard_register`

Default: `nil` use `&clipboard`

Choose the register that is synced with ring (from above). If `&clipboard` is
empty then `*` is used.

### `ring.update_register_on_cycle`

Default: `false`

Using the `update_register_on_cycle` option, when you cycle through the ring,
the contents of the register used to update will be updated with the last
content cycled.

### `ring.permanent_wrapper`

Default: `nil`

Using the `permanent_wrapper` option, you can set a wrapper that will be used
for every put action. This is useful if you want to add a treatment to every
put actions (ex: remove `\r` for wsl support).

### Commands

You can clear yank history using `YankyClearHistory` command.

## 📜 Yank history picker

This allows you to select an entry in your recorded yank history using default
`vim.ui.select` neovim prompt (you can use [stevearc/dressing.nvim](https://github.com/stevearc/dressing.nvim/)
to customize this) or the awesome [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim).

It uses the same history as yank ring, so, if you want to increase history size,
just use [`ring.history_length` option](#ringhistory_length).

See [Integrations](#-integrations) to have a completion with [nvim-cmp](https://github.com/hrsh7th/nvim-cmp).

### Yank history completions

Using [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) and [cmp_yanky](https://github.com/chrisgrieser/cmp_yanky), you can also get suggestions from your yank history as you type in insert mode.

<details>
<summary>demonstration</summary>
<img src="https://github.com/chrisgrieser/cmp_yanky/assets/73286100/e1e62358-63d0-4261-88ed-47bb155576d2" alt="showcasing cmp-yanky" width=70%>
</details>

### ⚙️ Configuration

To use `vim.ui.select` picker, just call `YankyRingHistory` command.

To use the `yank_history` Telescope picker, register `yank_history` as a
Telescope extension in your Neovim config file.

```lua
:lua require("telescope").load_extension("yank_history")
```

After loading the extension, you can access the picker by running:

```vim
:Telescope yank_history
```

Or:

```lua
:lua require("telescope").extensions.yank_history.yank_history()
```

Set the Telescope option [`dynamic_preview_title`](https://github.com/nvim-telescope/telescope.nvim/blob/master/doc/telescope.txt)
to `true` if you want your Telescope preview window to have a
dynamic title showing the register's type.

Default configuration :

```lua
require("yanky").setup({
  picker = {
    select = {
      action = nil, -- nil to use default put action
    },
    telescope = {
      mappings = nil, -- nil to use default mappings
    },
  },
})
```

#### `picker.select.action`

Default : `nil`

This define the action that should be done when selecting an item in the
`vim.ui.select` prompt. If you let this option to `nil`, this will use the
default action : put selected item after cursor.

Available actions:

```lua
require("yanky.picker").actions.put("p") -- put after cursor
require("yanky.picker").actions.put("P") -- put before cursor
require("yanky.picker").actions.put("gp") -- put after cursor and leave the cursor after
require("yanky.picker").actions.put("gP") -- put before cursor and leave the cursor after
require("yanky.picker").actions.delete() -- delete entry from yank history
require("yanky.picker").actions.set_register(regname) -- fill register with selected value
require("yanky.picker").actions.put_and_set_register("p", regname) -- put and fill register with selected value
```

#### `picker.telescope.use_default_mappings`

Default : `true`

This define if default Telescope mappings should be use.

If you let this option to `true`, this will use the default mappings :

```lua
local utils = require("yanky.utils")
local mapping = require("yanky.telescope.mapping")

require("yanky").setup({
  picker = {
    telescope = {
      mappings = {
        default = mapping.put("p"),
        i = {
          ["<c-g>"] = mapping.put("p"),
          ["<c-k>"] = mapping.put("P"),
          ["<c-x>"] = mapping.delete(),
          ["<c-r>"] = mapping.set_register(utils.get_default_register()),
        },
        n = {
          p = mapping.put("p"),
          P = mapping.put("P"),
          d = mapping.delete(),
          r = mapping.set_register(utils.get_default_register())
        },
      }
    }
  }
})
```

#### `picker.telescope.mappings`

Default : `nil`

This define or overrides the mappings available in Telescope.

If you set `use_default_mappings` to `true`, mappings will be merged with default mappings.

**Available actions:**

```lua
require("yanky.telescope.mapping").put("p") -- put after cursor
require("yanky.telescope.mapping").put("P") -- put before cursor
require("yanky.telescope.mapping").put("gp") -- put after cursor and leave the cursor after
require("yanky.telescope.mapping").put("gP") -- put before cursor and leave the cursor after
require("yanky.telescope.mapping").delete() -- delete entry from yank history
require("yanky.telescope.mapping").set_register(regname) -- fill register {regname} with selected value
```

You can also use any of available [special puts](https://github.com/gbprod/yanky.nvim#%EF%B8%8F-special-put) like this:

```lua
require("yanky.telescope.mapping").special_put("{{ name of the special put }}")

-- eg.
require("yanky.telescope.mapping").special_put("YankyPutAfterCharwiseJoined")
```

## 💡 Highlight put and yanked text

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

#### `highlight.timer`

Default : `500`

Define the duration of highlight.

## ⤵️ Preserve cursor position on yank

By default in Neovim, when yanking text, cursor moves to the start of the yanked
text. Could be annoying especially when yanking a large text object such as a
paragraph or a large text object.

With this feature, yank will function exactly the same as previously with the one
difference being that the cursor position will not change after performing a yank.

### ⌨️ Mappings

```lua
vim.keymap.set({"n","x"}, "y", "<Plug>(YankyYank)")
```

### ⚙️ Configuration

```lua
require("yanky").setup({
  preserve_cursor_position = {
    enabled = true,
  },
})
```

#### `preserve_cursor_position.enabled`

Default : `true`

Define if cursor position should be preserved on yank. This works only if mappings
has been defined.

## ⭐ Special put

Yanky comes with special put moves (inspired by
[tpope/vim-unimpaired](https://github.com/tpope/vim-unimpaired/blob/master/doc/unimpaired.txt#L100)):

- Linewise put: this will force put above or below the current line ;
- Shift right/left put: will put above or below the current line and increasing
  or decreasing indent ;
- Filter put: will put above or below the current line and reindenting.

### ⌨️ Mappings

For basic usage (like with [tpope/vim-unimpaired](https://github.com/tpope/vim-unimpaired/blob/master/doc/unimpaired.txt#L100)),
you can use those bindings:

```lua
vim.keymap.set("n", "]p", "<Plug>(YankyPutIndentAfterLinewise)")
vim.keymap.set("n", "[p", "<Plug>(YankyPutIndentBeforeLinewise)")
vim.keymap.set("n", "]P", "<Plug>(YankyPutIndentAfterLinewise)")
vim.keymap.set("n", "[P", "<Plug>(YankyPutIndentBeforeLinewise)")

vim.keymap.set("n", ">p", "<Plug>(YankyPutIndentAfterShiftRight)")
vim.keymap.set("n", "<p", "<Plug>(YankyPutIndentAfterShiftLeft)")
vim.keymap.set("n", ">P", "<Plug>(YankyPutIndentBeforeShiftRight)")
vim.keymap.set("n", "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)")

vim.keymap.set("n", "=p", "<Plug>(YankyPutAfterFilter)")
vim.keymap.set("n", "=P", "<Plug>(YankyPutBeforeFilter)")
```

To go further, Plug mappings are constructed like this: `Yanky(put-type)(modifier)(rewriter)`.

`put-type` can be:

- `PutAfter`: put after your cursor (as [`p`](https://neovim.io/doc/user/change.html#put) key) ;
- `PutBefore`: put before your cursor (as [`P`](https://neovim.io/doc/user/change.html#P) key) ;
- `GPutAfter`: like `PutAfter` but leave the cursor after the new text (as [`gp`](https://neovim.io/doc/user/change.html#gp) key) ;
- `GPutBefore`: like `PutBefore` but leave the cursor after the new text (as [`gP`](https://neovim.io/doc/user/change.html#gP) key) ;
- `PutIndentAfter`: like `PutAfter` but adjust the indent to the current line (as [`]p`](https://neovim.io/doc/user/change.html#]p) key) ;
- `PutIndentBefore`: like `PutBefore` but adjust the indent to the current line (as [`[p`](https://neovim.io/doc/user/change.html#[p) key) ;

`modifier` (optional) can be:

- `Linewise`: put in linewise mode ;
- `Charwise`: put in charwise mode ;
- `Blockwise`: put in blockwise mode ;
- `ShiftRight`: increase indent ;
- `ShiftLeft`: decrease indent.

`rewriter` (optional) can be:

- `Joined`: put lines trimed and joined.

<details>
<summary><b>All special puts</b></summary>

```vim
<Plug>(YankyPutAfter)
<Plug>(YankyPutAfterBlockwise)
<Plug>(YankyPutAfterBlockwiseJoined)
<Plug>(YankyPutAfterCharwise)
<Plug>(YankyPutAfterCharwiseJoined)
<Plug>(YankyPutAfterFilter)
<Plug>(YankyPutAfterFilterJoined)
<Plug>(YankyPutAfterJoined)
<Plug>(YankyPutAfterLinewise)
<Plug>(YankyPutAfterLinewiseJoined)
<Plug>(YankyPutAfterShiftLeft)
<Plug>(YankyPutAfterShiftLeftJoined)
<Plug>(YankyPutAfterShiftRight)
<Plug>(YankyPutAfterShiftRightJoined)
<Plug>(YankyPutBefore)
<Plug>(YankyPutBeforeBlockwise)
<Plug>(YankyPutBeforeBlockwiseJoined)
<Plug>(YankyPutBeforeCharwise)
<Plug>(YankyPutBeforeCharwiseJoined)
<Plug>(YankyPutBeforeFilter)
<Plug>(YankyPutBeforeFilterJoined)
<Plug>(YankyPutBeforeJoined)
<Plug>(YankyPutBeforeLinewise)
<Plug>(YankyPutBeforeLinewiseJoined)
<Plug>(YankyPutBeforeShiftLeft)
<Plug>(YankyPutBeforeShiftLeftJoined)
<Plug>(YankyPutBeforeShiftRight)
<Plug>(YankyPutBeforeShiftRightJoined)
<Plug>(YankyGPutAfter)
<Plug>(YankyGPutAfterBlockwise)
<Plug>(YankyGPutAfterBlockwiseJoined)
<Plug>(YankyGPutAfterCharwise)
<Plug>(YankyGPutAfterCharwiseJoined)
<Plug>(YankyGPutAfterFilter)
<Plug>(YankyGPutAfterFilterJoined)
<Plug>(YankyGPutAfterJoined)
<Plug>(YankyGPutAfterLinewise)
<Plug>(YankyGPutAfterLinewiseJoined)
<Plug>(YankyGPutAfterShiftLeft)
<Plug>(YankyGPutAfterShiftLeftJoined)
<Plug>(YankyGPutAfterShiftRight)
<Plug>(YankyGPutAfterShiftRightJoined)
<Plug>(YankyGPutBefore)
<Plug>(YankyGPutBeforeBlockwise)
<Plug>(YankyGPutBeforeBlockwiseJoined)
<Plug>(YankyGPutBeforeCharwise)
<Plug>(YankyGPutBeforeCharwiseJoined)
<Plug>(YankyGPutBeforeFilter)
<Plug>(YankyGPutBeforeFilterJoined)
<Plug>(YankyGPutBeforeJoined)
<Plug>(YankyGPutBeforeLinewise)
<Plug>(YankyGPutBeforeLinewiseJoined)
<Plug>(YankyGPutBeforeShiftLeft)
<Plug>(YankyGPutBeforeShiftLeftJoined)
<Plug>(YankyGPutBeforeShiftRight)
<Plug>(YankyGPutBeforeShiftRightJoined)
<Plug>(YankyPutIndentAfter)
<Plug>(YankyPutIndentAfterBlockwise)
<Plug>(YankyPutIndentAfterBlockwiseJoined)
<Plug>(YankyPutIndentAfterCharwise)
<Plug>(YankyPutIndentAfterCharwiseJoined)
<Plug>(YankyPutIndentAfterFilter)
<Plug>(YankyPutIndentAfterFilterJoined)
<Plug>(YankyPutIndentAfterJoined)
<Plug>(YankyPutIndentAfterLinewise)
<Plug>(YankyPutIndentAfterLinewiseJoined)
<Plug>(YankyPutIndentAfterShiftLeft)
<Plug>(YankyPutIndentAfterShiftLeftJoined)
<Plug>(YankyPutIndentAfterShiftRight)
<Plug>(YankyPutIndentAfterShiftRightJoined)
<Plug>(YankyPutIndentBefore)
<Plug>(YankyPutIndentBeforeBlockwise)
<Plug>(YankyPutIndentBeforeBlockwiseJoined)
<Plug>(YankyPutIndentBeforeCharwise)
<Plug>(YankyPutIndentBeforeCharwiseJoined)
<Plug>(YankyPutIndentBeforeFilter)
<Plug>(YankyPutIndentBeforeFilterJoined)
<Plug>(YankyPutIndentBeforeJoined)
<Plug>(YankyPutIndentBeforeLinewise)
<Plug>(YankyPutIndentBeforeLinewiseJoined)
<Plug>(YankyPutIndentBeforeShiftLeft)
<Plug>(YankyPutIndentBeforeShiftLeftJoined)
<Plug>(YankyPutIndentBeforeShiftRight)
<Plug>(YankyPutIndentBeforeShiftRightJoined)
```

</details>

## ⚓ Text object

Yanky comes with a text object corresponding to last put text. To use it, you
have to enable it in settings and set a keymap.

### ⚙️ Configuration

```lua
require("yanky").setup({
  textobj = {
    enabled = false,
  },
})
```

### ⌨️ Mappings

```lua
vim.keymap.set({ "o", "x" }, "iy", function()
  require("yanky.textobj").last_put()
end, {})
```

## 🎨 Colors

| Description                     | Group       | Default        |
| ------------------------------- | ----------- | -------------- |
| Highlight color for put text    | YankyPut    | link to Search |
| Highlight color for yanked text | YankyYanked | link to Search |

## 🤝 Integrations

<details>
<summary><b>gbprod/substitute.nvim</b></summary>

To enable [gbprod/substitute.nvim](https://github.com/gbprod/substitute.nvim)
swap when performing a substitution, you can add this to your setup:

```lua
require("substitute").setup({
  on_substitute = require("yanky.integration").substitute(),
})
```

or

```lua
opts = {
  on_substitute = function() require("yanky.integration").substitute() end,
}
```

</details>

<details>
<summary><b>hrsh7th/nvim-cmp</b></summary>

Using [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp) and [chrisgrieser/cmp_yanky](https://github.com/chrisgrieser/cmp_yanky), you can also get suggestions from your yank history as you type in insert mode.

<img src="https://github.com/chrisgrieser/cmp_yanky/assets/73286100/e1e62358-63d0-4261-88ed-47bb155576d2" alt="showcasing cmp-yanky" width=70%>
</details>

<details>
<summary><b>anuvyklack/hydra.nvim</b></summary>

To work with [anuvyklack/hydra.nvim](https://github.com/anuvyklack/hydra.nvim)
only setup <C-n>/<C-p> mapping when yanky is activated, you can add this to your setup:

```lua
local Hydra = require("hydra")

local function t(str)
  return api.nvim_replace_termcodes(str, true, true, true)
end

local yanky_hydra = Hydra({
  name = "Yank ring",
  mode = "n",
  heads = {
    { "p", "<Plug>(YankyPutAfter)", { desc = "After" } },
    { "P", "<Plug>(YankyPutBefore)", { desc = "Before" } },
    { "<c-p>", "<Plug>(YankyPreviousEntry)", { private = true, desc = "↑" } },
    { "<c-n>", "<Plug>(YankyNextEntry)", { private = true, desc = "↓" } },
  },
})

-- choose/change the mappings if you want
for key, putAction in pairs({
  ["p"] = "<Plug>(YankyPutAfter)",
  ["P"] = "<Plug>(YankyPutBefore)",
  ["gp"] = "<Plug>(YankyGPutAfter)",
  ["gP"] = "<Plug>(YankyGPutBefore)",
}) do
  vim.keymap.set({ "n", "x" }, key, function()
    vim.fn.feedkeys(t(putAction))
    yanky_hydra:activate()
  end)
end

-- choose/change the mappings if you want
for key, putAction in pairs({
  ["]p"] = "<Plug>(YankyPutIndentAfterLinewise)",
  ["[p"] = "<Plug>(YankyPutIndentBeforeLinewise)",
  ["]P"] = "<Plug>(YankyPutIndentAfterLinewise)",
  ["[P"] = "<Plug>(YankyPutIndentBeforeLinewise)",

  [">p"] = "<Plug>(YankyPutIndentAfterShiftRight)",
  ["<p"] = "<Plug>(YankyPutIndentAfterShiftLeft)",
  [">P"] = "<Plug>(YankyPutIndentBeforeShiftRight)",
  ["<P"] = "<Plug>(YankyPutIndentBeforeShiftLeft)",

  ["=p"] = "<Plug>(YankyPutAfterFilter)",
  ["=P"] = "<Plug>(YankyPutBeforeFilter)",
}) do
  vim.keymap.set("n", key, function()
    vim.fn.feedkeys(t(putAction))
    yanky_hydra:activate()
  end)
end
```

</details>

<details>
  <summary><b>windows wsl</b></summary>
When pasting text from windows system clipboard, there's always a ^M at the end
of each line. Adding a permeant wrapper to remove these ^M characters when pasting
will allows you to paste text from windows system clipboard without any issues.

```lua
require("yanky").setup({
  ring = {
    permanent_wrapper = require("yanky.wrappers").remove_carriage_return,
  },
})
```

</details>

## 🎉 Credits

This plugin is mostly a lua version of [svermeulen/vim-yoink](https://github.com/svermeulen/vim-yoink)
awesome plugin.

Other inspiration :

- [bfredl/nvim-miniyank](https://github.com/bfredl/nvim-miniyank)
- [maxbrunsfeld/vim-yankstack](https://github.com/maxbrunsfeld/vim-yankstack)
- [svermeulen/vim-easyclip](https://github.com/svermeulen/vim-easyclip)
- [bkoropoff/yankee.vim](https://github.com/bkoropoff/yankee.vim)
- [svban/YankAssassin.vim](https://github.com/svban/YankAssassin.vim)
- [tpope/vim-unimpaired](https://github.com/tpope/vim-unimpaired)
- [inkarkat/vim-UnconditionalPaste](https://github.com/inkarkat/vim-UnconditionalPaste)
