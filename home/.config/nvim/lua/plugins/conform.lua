return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" }, -- Carga el plugin antes de guardar un archivo
  cmd = { "ConformInfo" },
  keys = {
    {
      -- Tu atajo para formatear manualmente
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format",
    },
  },
  opts = {
    -- Aquí defines qué formateador usar para cada lenguaje
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      css = { "prettier" },
      html = { "prettier" },
      json = { "prettier" },
      markdown = { "prettier" },
      yaml = { "prettier" },
      lua = { "stylua" },
      cs = { "csharpier" },      -- Archivos de C# (.NET)
      sql = { "sql_formatter" }, -- Scripts de SQL
    },
    -- Descomenta la siguiente sección si quieres que se formatee automáticamente al guardar
    -- format_on_save = {
    --   timeout_ms = 500,
    --   lsp_fallback = true,
    -- },
  },
}
