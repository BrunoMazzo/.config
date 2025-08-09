return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    picker = { enabled = true },
    scope = { enabled = true },
    -- scroll = { enabled = true },
    statuscolumn = { enabled = false }, -- we set this in options.lua
    --    toggle = { map = LazyVim.safe_keymap_set },
    words = { enabled = true },
    styles = {
      lazygit = {
        height = 0,
        width = 0,
      },
    },
  },
  -- stylua: ignore
  keys = {
    { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notification History" },
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
  },
}
