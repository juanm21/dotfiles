vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- libera lo buscado con los comandos / o ? 
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
-- select all
vim.keymap.set('n', '<C-a>', 'ggVG', { desc = 'Select All' })
-- pasting over a selection no longer clobbers your clipboard
vim.cmd([[ xnoremap <expr> p 'pgv"'.v:register.'y' ]])
