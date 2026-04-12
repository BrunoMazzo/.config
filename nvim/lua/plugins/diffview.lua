-- diffview configuration
-- vim.pack version - no lazy loading

-- Add the plugin
vim.pack.add({"https://github.com/sindrets/diffview.nvim.git"})

-- Configure the plugin
require("diffview").setup({
  diff_binaries = false,
  enhanced_diff_hl = false,
  git_cmd = { "git" },
  use_icons = true,
  show_help_hints = true,
  watch_index = true,
  icons = {
    folder_closed = "",
    folder_open = "",
  },
  signs = {
    fold_closed = "",
    fold_open = "",
    done = "",
  },
})
