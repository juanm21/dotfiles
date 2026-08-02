-- Debug de C#/.NET en macOS Apple Silicon.
-- Mason instala netcoredbg x86_64 (Samsung no publica builds osx-arm64),
-- que no puede debuggear el runtime dotnet arm64 nativo: el launch se cuelga.
-- Este plugin trae un build arm64 de netcoredbg y su setup() sobreescribe
-- los adaptadores coreclr/netcoredbg que registra el extra lang.dotnet.
return {
  { "Cliffback/netcoredbg-macOS-arm64.nvim", lazy = true },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = { "Cliffback/netcoredbg-macOS-arm64.nvim" },
    opts = function()
      require("netcoredbg-macOS-arm64").setup(require("dap"))
    end,
  },
  -- mason-nvim-dap registra coreclr apuntando al netcoredbg x64 de Mason y
  -- pisaría el adaptador arm64; este handler no-op se lo impide.
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = {
      handlers = {
        coreclr = function() end,
      },
    },
  },
}
