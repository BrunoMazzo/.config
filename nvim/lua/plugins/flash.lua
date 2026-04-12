-- Flash configuration
-- vim.pack version - no lazy loading

-- Add the plugin
vim.pack.add({"https://github.com/folke/flash.nvim.git"})

-- Configure the plugin
require("flash").setup({
  exclude = {
    "notify",
    "cmp_menu",
    "noice",
    "flash_prompt",
    "OverseerList",
    function(win)
      return not vim.api.nvim_win_get_config(win).focusable
    end,
  },
})

-- Keymaps
vim.keymap.set({ "n", "x", "o" }, "s", function()
  require("flash").jump()
end, { desc = "Flash" })

vim.keymap.set({ "n", "x", "o" }, "S", function()
  require("flash").treesitter()
end, { desc = "Flash Treesitter" })

vim.keymap.set("o", "r", function()
  require("flash").remote()
end, { desc = "Remote Flash" })

vim.keymap.set({ "o", "x" }, "R", function()
  require("flash").treesitter_search()
end, { desc = "Treesitter Search" })

vim.keymap.set("c", "<c-s>", function()
  require("flash").toggle()
end, { desc = "Toggle Flash Search" })
