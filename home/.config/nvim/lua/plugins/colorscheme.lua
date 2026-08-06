return {
  {
    "folke/tokyonight.nvim",
    lazy = false,    -- Asegura que el tema cargue inmediatamente al abrir Neovim
    priority = 1000, -- Evita que otros plugins carguen antes y arruinen los colores
    config = function()
      -- Aquí es donde realmente le dices a Neovim que active el tema
      vim.cmd.colorscheme("tokyonight-night")
    end,
  }
}

