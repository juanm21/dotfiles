return {
  "echasnovski/mini.statusline",
  version = "*", -- Utiliza la última versión estable (recomendado para los plugins de mini)
  config = function()
    require("mini.statusline").setup({

  content = {
    -- Content for active window
    active = nil,
    -- Content for inactive window(s)
    inactive = nil,
  },

  -- Whether to use icons by default
  use_icons = true,


    })
  end
}

