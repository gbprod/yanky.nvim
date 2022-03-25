set rtp+=.
set rtp+=vendor/plenary.nvim/

runtime plugin/plenary.vim
runtime plugin/yanky.vim

lua require('plenary.busted')
lua require('yanky').setup({ ring = { storage = "memory" }})

lua vim.api.nvim_set_keymap("n", "p", "<Plug>(YankyPutAfter)", {})
lua vim.api.nvim_set_keymap("n", "P", "<Plug>(YankyPutBefore)", {})
lua vim.api.nvim_set_keymap("x", "p", "<Plug>(YankyPutAfter)", {})
lua vim.api.nvim_set_keymap("x", "P", "<Plug>(YankyPutBefore)", {})

lua vim.api.nvim_set_keymap("n", "gp", "<Plug>(YankyGPutAfter)", {})
lua vim.api.nvim_set_keymap("n", "gP", "<Plug>(YankyGPutBefore)", {})
lua vim.api.nvim_set_keymap("x", "gp", "<Plug>(YankyGPutAfter)", {})
lua vim.api.nvim_set_keymap("x", "gP", "<Plug>(YankyGPutBefore)", {})

lua vim.api.nvim_set_keymap("n", ",p", "<Plug>(YankyCycleForward)", {})
lua vim.api.nvim_set_keymap("n", ",P", "<Plug>(YankyCycleBackward)", {})

lua vim.api.nvim_set_keymap("n", "y", "<Plug>(YankyYank)", {})
lua vim.api.nvim_set_keymap("x", "y", "<Plug>(YankyYank)", {})
