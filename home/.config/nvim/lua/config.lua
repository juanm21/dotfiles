local opt = vim.opt

opt.showmode = true
opt.guicursor = "i:ver25" -- Use block cursor in insert mode
opt.colorcolumn = "80" -- Highight column 80
opt.signcolumn = "yes:1" -- Always show sign column
opt.termguicolors = true -- Enable true colors
opt.ignorecase = true -- Ignore case in search
opt.swapfile = false -- Disable swap file
opt.autoindent = true -- Enable auto indentation
opt.expandtab = true -- spaces, not tabs
opt.tabstop = 2 -- Number of spaces for a tab
opt.softtabstop = 2 -- Number of spaces for a tab when editing
opt.shiftwidth = 2 -- Number of spaces for autoindent
opt.shiftround = true -- Round indent to multiple of shiftwidth
opt.listchars = "tab: ,multispace:|   ,eol:󰌑" -- Characters to show for tabs, spaces, and end of line
opt.list = true -- Show whitespace characters
opt.number = true -- absolute number on the cursor line, relative elsewhere
opt.relativenumber = true -- relative line numbers for fast jumps
opt.numberwidth = 4 -- Widh of the line number column
opt.wrap = true -- Line wrapping
opt.cursorline = true -- Highlight the current line
opt.scrolloff = 16 -- keep cursor away from the screen edge
opt.inccommand = "nosplit" -- Shows the effects of a command incrementally in the buffer
opt.undofile = true -- persistent undo across sessions
opt.completeopt = { "menuone", "popup", "noinsert" } -- Options for completion menu
opt.winborder = "rounded" -- Use rounded borders for windows
opt.hlsearch = true -- Highlighting of search results
opt.smartcase = true -- case-sensitive only if i type a capital
opt.clipboard = 'unnamedplus' -- share the system clipboard

vim.cmd.filetype("plugin indent on") -- Enable filetype detection, plugins, and indentation
