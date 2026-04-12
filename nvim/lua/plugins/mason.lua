-- Mason configuration
-- vim.pack version - no lazy loading

-- Add dependencies first
vim.pack.add({"https://github.com/williamboman/mason.nvim.git"})
vim.pack.add({"https://github.com/williamboman/mason-lspconfig.nvim.git"})

-- Configure mason
require("mason").setup()
