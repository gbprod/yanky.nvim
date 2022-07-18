set rtp+=.
set rtp+=vendor/plenary.nvim/

runtime plugin/plenary.vim

lua require('plenary.busted')
lua require('yanky').setup({ ring = { storage = "memory" }})
lua require('yanky').register_plugs()

lua vim.keymap.set("n", "p", "<Plug>(YankyPutAfter)", {})
lua vim.keymap.set("n", "P", "<Plug>(YankyPutBefore)", {})
lua vim.keymap.set("x", "p", "<Plug>(YankyPutAfter)", {})
lua vim.keymap.set("x", "P", "<Plug>(YankyPutBefore)", {})

lua vim.keymap.set("n", "gp", "<Plug>(YankyGPutAfter)", {})
lua vim.keymap.set("n", "gP", "<Plug>(YankyGPutBefore)", {})
lua vim.keymap.set("x", "gp", "<Plug>(YankyGPutAfter)", {})
lua vim.keymap.set("x", "gP", "<Plug>(YankyGPutBefore)", {})

lua vim.keymap.set("n", ",p", "<Plug>(YankyCycleForward)", {})
lua vim.keymap.set("n", ",P", "<Plug>(YankyCycleBackward)", {})

lua vim.keymap.set("n", "y", "<Plug>(YankyYank)", {})
lua vim.keymap.set("x", "y", "<Plug>(YankyYank)", {})
