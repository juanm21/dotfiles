return {
  "hrsh7th/nvim-cmp",
  -- Definimos las fuentes de autocompletado como dependencias
  dependencies = {
    "hrsh7th/cmp-cmdline", -- Sugerencias para la línea de comandos (:) y (/)
    "hrsh7th/cmp-buffer",  -- Sugerencias basadas en el texto del archivo actual
    "hrsh7th/cmp-path",    -- Sugerencias de rutas de archivos locales
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/nvim-cmp",
    --"echasnovski/mini.snippets",
    --"abeldekat/cmp-mini-snippets",
  },
  config = function()
    local cmp = require("cmp")

    -- 1. Configuración global básica para cuando escribes código/texto
    cmp.setup({
      mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      }),
      sources = cmp.config.sources({
        { name = 'buffer' },
      })
    })

    -- 2. Configuración específica para sugerencias al buscar con (/)
    cmp.setup.cmdline('/', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' }
      }
    })

    -- 3. Configuración específica para sugerencias al escribir comandos con (:)
    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = 'path' } -- Sugiere rutas si escribes comandos como :e /home/
      }, {
        { name = 'cmdline' } -- Sugiere comandos de Neovim
      }),
      matching = { disallow_symbol_nonprefix_matching = false }
    })
  end
}
