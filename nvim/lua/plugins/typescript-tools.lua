-- typescript-tools configuration
-- vim.pack version - no lazy loading
-- NOTE: Currently disabled

-- Add the plugin (even if disabled, it's good to have it available)
vim.pack.add({"https://github.com/pmizio/typescript-tools.nvim.git"})

-- Uncomment to enable typescript-tools
--[[
require("typescript-tools").setup({
  settings = {
    publish_diagnostic_on = "change"
  }
})
--]]
