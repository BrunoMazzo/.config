-- nvim-coverage configuration
-- vim.pack version - no lazy loading

-- Add dependencies first
vim.pack.add({ "https://github.com/nvim-neotest/nvim-nio.git" })

-- Add the main plugin
vim.pack.add({ "https://github.com/andythigpen/nvim-coverage.git" })

-- Configure the plugin
require("coverage").setup({
  auto_reload = true,
})

-- Keymaps
vim.keymap.set("n", "<leader>uc", "<cmd>CoverageLoad<cr><cmd>CoverageToggle<cr>", { desc = "Toggle Coverage" })
