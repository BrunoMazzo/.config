-- Avante configuration
-- vim.pack version - no lazy loading
-- NOTE: Currently disabled

-- Add the plugin (even if disabled, it's good to have it available)
vim.pack.add({"https://github.com/yetone/avante.nvim.git"})

-- Uncomment to enable avante
--[[
require("avante").setup({
  provider = "claude",
  auto_suggestions_provider = "claude",
  behaviour = {
    auto_suggestions = true,
    auto_set_highlight_group = true,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = false,
    support_paste_from_clipboard = false,
    minimize_diff = true,
  },
})
--]]
