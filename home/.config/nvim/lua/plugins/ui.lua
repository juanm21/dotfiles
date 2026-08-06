return {
  {
    'folke/which-key.nvim',
    lazy = false,
    config = true, -- popup that shows what my leader keys do
  },
  {
    -- Proveedor de íconos (Nerd Font) para oil, snacks, neogit, etc.
    'nvim-mini/mini.icons',
    lazy = false,
    priority = 900, -- antes que oil/snacks, que lo consultan al cargar
    opts = {},
    init = function()
      -- Los plugins que piden 'nvim-web-devicons' reciben mini.icons en su lugar,
      -- así no hay que instalar los dos.
      package.preload['nvim-web-devicons'] = function()
        require('mini.icons').mock_nvim_web_devicons()
        return package.loaded['nvim-web-devicons']
      end
    end,
  },
}
