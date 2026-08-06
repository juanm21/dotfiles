return {
  {
    'stevearc/oil.nvim',
    -- lazy = false: oil tiene que estar cargado ANTES de abrir un buffer de
    -- directorio (`nvim .`, `:e src/`), si no netrw gana. El propio plugin
    -- desaconseja el lazy-load.
    lazy = false,
    dependencies = { 'nvim-mini/mini.icons' },
    opts = {
      default_file_explorer = true, -- toma los buffers de directorio (reemplaza netrw)
      view_options = { show_hidden = true },
      skip_confirm_for_simple_edits = true,
      delete_to_trash = true, -- borrar manda a la papelera, no es definitivo
    },
    keys = {
      { '<leader>e', '<cmd>Oil<cr>', desc = 'File Browser' },
      { '-', '<cmd>Oil<cr>', desc = 'Open parent directory' },
    },
  },
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      picker = { enabled = true },
      notifier = { enabled = true },
      input = { enabled = true },
    },
    keys = {
      { '<leader>f', function() Snacks.picker.files() end, desc = 'Find Files' },
      { '<leader>s', function() Snacks.picker.grep() end,  desc = 'Search Text' },
      { '<leader>b', function() Snacks.picker.buffers() end, desc = 'Buffers' },
      { 'gd', function() Snacks.picker.lsp_definitions() end, desc = 'Goto Definition' },
    },
  },
} 
