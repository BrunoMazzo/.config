-- nvim-treesitter-context configuration
-- vim.pack version - no lazy loading
-- NOTE: Currently disabled

-- Add the plugin (even if disabled, it's good to have it available)
vim.pack.add({"https://github.com/nvim-treesitter/nvim-treesitter-context.git"})

-- Uncomment to enable treesitter-context
--[[
require("treesitter-context").setup({
  mode = "cursor",
  max_lines = 3,
})

vim.keymap.set("n", "<leader>ut", function()
  local tsc = require("treesitter-context")
  if tsc.enabled() then
    tsc.disable()
  else
    tsc.enable()
  end
end, { desc = "Toggle Treesitter Context" })
--]]
