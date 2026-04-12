-- fidget configuration
-- vim.pack version - no lazy loading

-- Add the plugin
vim.pack.add({"https://github.com/j-hui/fidget.nvim.git"})

-- Configure the plugin
require("fidget").setup({
  notification = {
    window = {
      normal_hl = "String",
      winblend = 0,
      border = "rounded",
      zindex = 45,
      max_width = 0,
      max_height = 0,
      x_padding = 1,
      y_padding = 1,
      align = "bottom",
      relative = "editor",
    },
  },
})
