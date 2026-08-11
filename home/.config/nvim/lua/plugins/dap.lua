return {
  "mfussenegger/nvim-dap",
  keys = {
    { "<leader>dc", function() require("dap").continue() end, desc = "Start/Continue Debug" },
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Add Breakpoint" },
    { "<leader>do", function() require("dap").step_over() end, desc = "Step Over" },
    { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
  },
  config = function()
    local dap = require("dap")

    -- 1. Definimos el adaptador apuntando al binario que instalaste con Nix
    dap.adapters.coreclr = {
      type = "executable",
      command = "netcoredbg",
      args = { "--interpreter=vscode" },
    }

    -- 2. Configuramos cómo arrancar un proyecto de C#
    dap.configurations.cs = {
      {
        type = "coreclr",
        name = "Launch - netcoredbg",
        request = "launch",
        -- Neovim te preguntará la ruta del archivo .dll compilado a depurar
        program = function()
          return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
        end,
      },
    }
  end,
}
