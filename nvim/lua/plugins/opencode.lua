-- opencode.nvim configuration
-- Integrates the OpenCode AI assistant with Neovim
-- https://github.com/nickjvandyke/opencode.nvim
--
-- Tracks the plugin's `main` branch, which supports OpenCode v2.
-- (`vim.version.range("*")` would pin to the v1-compatible stable release.)

-- Add the plugin
vim.pack.add({ "https://github.com/nickjvandyke/opencode.nvim.git" })

-- Configuration
---@type opencode.Opts
vim.g.opencode_opts = {
  -- Defaults are sensible; see lua/opencode/config.lua in the plugin for all options
}

-- Ask OpenCode about the cursor/selection
vim.keymap.set({ "n", "x" }, "<leader>o", function()
  require("opencode").ask("@this: ")
end, { desc = "Ask OpenCode…" })

-- Select a prompt, command, session, or other OpenCode action
vim.keymap.set({ "n", "x" }, "<leader>os", function()
  require("opencode").select()
end, { desc = "Select OpenCode action…" })
