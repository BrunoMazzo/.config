-- Oil configuration
-- vim.pack version - no lazy loading

-- Add the plugin
vim.pack.add({"https://github.com/stevearc/oil.nvim.git"})

-- Configure the plugin
require("oil").setup({})

-- Keymaps
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open Oil" })
