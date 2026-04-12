-- Toggleterm configuration
-- vim.pack version - no lazy loading

-- Add the plugin
vim.pack.add({"https://github.com/akinsho/toggleterm.nvim.git"})

-- Configure the plugin
require("toggleterm").setup({
  open_mapping = [[<c-t>]],
})
