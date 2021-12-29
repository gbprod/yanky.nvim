nnoremap <silent> <Plug>(YankyPutAfter) <cmd>lua require('yanky').put('p', false)<cr>
nnoremap <silent> <Plug>(YankyPutBefore) <cmd>lua require('yanky').put('P', false)<cr>
xnoremap <silent> <Plug>(YankyPutAfter) <cmd>lua require('yanky').put('p', true)<cr>
xnoremap <silent> <Plug>(YankyPutBefore) <cmd>lua require('yanky').put('P', true)<cr>

nnoremap <silent> <Plug>(YankyCycleForward) <cmd>lua require('yanky').cycle(1)<cr>
nnoremap <silent> <Plug>(YankyCycleBackward) <cmd>lua require('yanky').cycle(-1)<cr>
