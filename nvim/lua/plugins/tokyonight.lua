-- TokyoNight colorscheme configuration
-- vim.pack version - no lazy loading

-- Add the plugin
vim.pack.add({"https://github.com/folke/tokyonight.nvim.git"})

-- Configure the plugin
require("tokyonight").setup({
  style = "night",
  transparent = false,
  terminal_colors = true,
  styles = {
    comments = { italic = true },
    keywords = { italic = true },
    functions = {},
    variables = {},
    sidebars = "dark",
    floats = "dark",
  },
  sidebars = { "qf", "help", "neo-tree", "terminal", "packer" },
  day_brightness = 0.3,
  hide_inactive_statusline = false,
  dim_inactive = false,
  lualine_bold = false,
})
