-- Snacks.nvim configuration
-- vim.pack version - no lazy loading

-- Add the plugin
vim.pack.add({ "https://github.com/folke/snacks.nvim.git" })

-- Configure the plugin
require("snacks").setup({
  dashboard = {
    enabled = true,
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
      -- {
      --   section = "terminal",
      --   cmd = "echo 'Loading...' && git fetch --all && git log --oneline -10 main 2>/dev/null || git log --oneline -10 master 2>/dev/null || echo 'Not a git repository'",
      --   height = 5,
      --   pane = 2,
      --   indent = 2,
      -- },
    },
    preset = {
      header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
      ]],
      keys = {
        { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
        { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
        {
          icon = " ",
          key = "c",
          desc = "Config",
          action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
        },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      },
    },
  },
  indent = { enabled = true },
  input = { enabled = true },
  notifier = { enabled = true },
  picker = {
    enabled = true,
    -- OpenCode integration for enhanced select() functionality
    actions = {
      opencode_send = function(picker)
        local items = vim.tbl_map(function(item)
          return item.file and require("opencode").format({ path = item.file, from = item.pos, to = item.end_pos })
            or item.text
        end, picker:selected({ fallback = true }))

        require("opencode").prompt(table.concat(items, ", ") .. " ")
      end,
    },
    win = {
      input = {
        keys = {
          ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
        },
      },
    },
  },
  scope = { enabled = true },
  statuscolumn = { enabled = false },
  words = { enabled = true },
  styles = {
    lazygit = {
      height = 0,
      width = 0,
    },
  },
})

-- Keymaps
vim.keymap.set("n", "<leader>n", function()
  Snacks.notifier.show_history()
end, { desc = "Notification History" })

vim.keymap.set("n", "<leader>un", function()
  Snacks.notifier.hide()
end, { desc = "Dismiss All Notifications" })
