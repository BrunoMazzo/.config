-- mini.pairs configuration
-- vim.pack version - no lazy loading

-- Add the plugin (mini.nvim contains all mini modules)
vim.pack.add({"https://github.com/echasnovski/mini.nvim.git"})

-- Configure the plugin
require("mini.pairs").setup()
