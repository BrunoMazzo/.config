-- Auto-session configuration
-- vim.pack version - no lazy loading
-- NOTE: Currently disabled

-- Add the plugin (even if disabled, it's good to have it available)
vim.pack.add({"https://github.com/rmagatti/auto-session.git"})

-- Uncomment to enable auto-session
--[[
require("auto-session").setup({
  auto_save = true,
  auto_restore = true,
})

vim.keymap.set("n", "<leader>wr", "<cmd>SessionRestore<CR>", { desc = "Restore session for cwd" })
vim.keymap.set("n", "<leader>ws", "<cmd>SessionSave<CR>", { desc = "Save session for auto session root dir" })
--]]
