local o = vim.opt
vim.g.mapleader = ' ' -- space is the leader key
-- netrw NO se desactiva acá: oil.nvim lo reemplaza con default_file_explorer
-- (borra los autocmds de FileExplorer). Ver lua/plugins/navigation.lua

o.expandtab = true -- spaces, not tabs
o.shiftwidth = 2 -- 2 spaces per indent level
o.number = true -- absolute number on the cursor line, relative elsewhere
o.relativenumber = true -- relative line numbers for fast jumps
o.ignorecase = true -- search is case-insensitive by default
o.smartcase = true -- case-sensitive only if i type a capital
o.clipboard = 'unnamedplus' -- share the system clipboard
o.scrolloff = 16 -- keep cursor away from the screen edge
o.undofile = true -- persistent undo across sessions
