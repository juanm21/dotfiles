return {
  "neovim/nvim-lspconfig",
  -- Lazy.nvim manejará los atajos de forma segura sin generar errores de "LHS"
  keys = {
    { "K", function() vim.lsp.buf.hover() end, desc = "Ver documentación" },
    { "rn", function() vim.lsp.buf.rename() end, desc = "Renombrar" },
    { "ca", function() vim.lsp.buf.code_action() end, desc = "Acciones de código" },
  },
  config = function()
    -- Volvemos a la configuración tradicional de lspconfig. 
    -- Nota: Si ves un mensaje de "deprecated", ignóralo. Es solo una 
    -- advertencia a futuro de los desarrolladores del plugin, pero es 
    -- la forma más estable de configurarlo en tu versión actual.
    require("lspconfig").omnisharp.setup({
      cmd = { "OmniSharp" },
      enable_roslyn_analyzers = true,
      enable_import_completion = true,
      organize_imports_on_format = true,
    })
  end,
}
