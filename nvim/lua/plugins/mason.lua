return {
    {
    "mason-org/mason.nvim",
    opts = {}
  },
  -- {
  --   "williamboman/mason-lspconfig.nvim",
  --   dependencies = {
  --     "williamboman/mason.nvim",
  --   },
  --   config = function()
  --     require("mason-lspconfig").setup({
  --       automatic_installation = true,
  --       ensure_installed = {
  --         "lua_ls",
  --         -- Typescript tools is managing it
  --         -- "ts_ls",
  --       },
  --     })
  --   end,
  -- },
  -- {
  --   "WhoIsSethDaniel/mason-tool-installer.nvim",
  --   dependencies = { "williamboman/mason.nvim" },
  --   config = function()
  --     local mason_tool_installer = require("mason-tool-installer")
  --     mason_tool_installer.setup({
  --       ensure_installed = {
  --         "stylua",
  --         "eslint_d",
  --       },
  --     })
  --   end,
  -- },
  -- {
  --   "jay-babu/mason-nvim-dap.nvim",
  --   dependencies = { "williamboman/mason.nvim" },
  --   config = function()
  --     local mason_dap = require("mason-nvim-dap")
  --     mason_dap.setup({
  --       automatic_installation = true,
  --       ensure_installed = {
  --         "delve",
  --         "js-debug-adapter",
  --       },
  --     })
  --   end,
  -- },
}
