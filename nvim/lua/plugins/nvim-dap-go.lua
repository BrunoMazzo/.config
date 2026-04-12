-- nvim-dap-go configuration
-- vim.pack version - no lazy loading

-- Add the plugin
vim.pack.add({"https://github.com/leoluz/nvim-dap-go.git"})

-- Configure the plugin
require("dap-go").setup()
