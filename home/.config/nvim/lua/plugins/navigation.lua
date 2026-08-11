return {
  {
    'stevearc/oil.nvim',
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
      { '<leader>ff', function() Snacks.picker.files() end, desc = 'Find Files' },
      { '<leader>fg', function() Snacks.picker.grep() end,  desc = 'Search Text' },
      { '<leader>fb', function() Snacks.picker.buffers() end, desc = 'Buffers' },
      { '<leader>fr', function() Snacks.picker.recent() end, desc = 'Recent' },

      { 'gd', function() Snacks.picker.lsp_definitions() end, desc = 'Goto Definition' },
      { 'gr', function() Snacks.picker.lsp_references() end, desc = 'Goto Reference' },
    },
  },
  } 
