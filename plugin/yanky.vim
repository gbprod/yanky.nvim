nnoremap <silent> <Plug>(YankyPutAfter) <cmd>lua require('yanky').put('p', false)<cr>
nnoremap <silent> <Plug>(YankyPutBefore) <cmd>lua require('yanky').put('P', false)<cr>
xnoremap <silent> <Plug>(YankyPutAfter) <cmd>lua require('yanky').put('p', true)<cr>
xnoremap <silent> <Plug>(YankyPutBefore) <cmd>lua require('yanky').put('P', true)<cr>

nnoremap <silent> <Plug>(YankyGPutAfter) <cmd>lua require('yanky').put('gp', false)<cr>
nnoremap <silent> <Plug>(YankyGPutBefore) <cmd>lua require('yanky').put('gP', false)<cr>
xnoremap <silent> <Plug>(YankyGPutAfter) <cmd>lua require('yanky').put('gp', true)<cr>
xnoremap <silent> <Plug>(YankyGPutBefore) <cmd>lua require('yanky').put('gP', true)<cr>

nnoremap <silent> <Plug>(YankyCycleForward) <cmd>lua require('yanky').cycle(1)<cr>
nnoremap <silent> <Plug>(YankyCycleBackward) <cmd>lua require('yanky').cycle(-1)<cr>

nnoremap <silent> <expr> <Plug>(YankyYank) v:lua.require('yanky').yank()
xnoremap <silent> <expr> <Plug>(YankyYank) v:lua.require('yanky').yank()
