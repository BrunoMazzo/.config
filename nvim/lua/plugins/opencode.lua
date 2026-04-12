-- opencode.nvim configuration
-- Integrates the opencode AI assistant with Neovim
-- https://github.com/nickjvandyke/opencode.nvim

-- Add the plugin
vim.pack.add({ "https://github.com/nickjvandyke/opencode.nvim.git" })

-- Configuration
---@type opencode.Opts
vim.g.opencode_opts = {
  -- Default configuration - check lua/opencode/config.lua for all options
  -- You can customize here if needed
}

-- Required for opts.events.reload
vim.o.autoread = true

-- Set up keymaps
-- Ask opencode (Ctrl+a)
vim.keymap.set({ "n", "x" }, "<C-a>", function()
  require("opencode").ask("@this: ", { submit = true })
end, { desc = "Ask opencode…" })

-- Execute opencode action (Ctrl+x)
vim.keymap.set({ "n", "x" }, "<C-x>", function()
  require("opencode").select()
end, { desc = "Execute opencode action…" })

-- Toggle opencode terminal (Ctrl+.)
vim.keymap.set({ "n", "t" }, "<C-.>", function()
  require("opencode").toggle()
end, { desc = "Toggle opencode" })

-- Operator mode - add range to opencode (go)
vim.keymap.set({ "n", "x" }, "go", function()
  return require("opencode").operator("@this ")
end, { desc = "Add range to opencode", expr = true })

-- Operator mode - add line to opencode (goo)
vim.keymap.set("n", "goo", function()
  return require("opencode").operator("@this ") .. "_"
end, { desc = "Add line to opencode", expr = true })

-- Scroll opencode up
vim.keymap.set("n", "<S-C-u>", function()
  require("opencode").command("session.half.page.up")
end, { desc = "Scroll opencode up" })

-- Scroll opencode down
vim.keymap.set("n", "<S-C-d>", function()
  require("opencode").command("session.half.page.down")
end, { desc = "Scroll opencode down" })

-- Optional: Remap increment/decrement since <C-a> and <C-x> are used
vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })
