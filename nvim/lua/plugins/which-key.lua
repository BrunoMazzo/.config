-- Which-key configuration
-- vim.pack version - no lazy loading

-- Add the plugin
vim.pack.add({"https://github.com/folke/which-key.nvim.git"})

-- Configure the plugin
require("which-key").setup({
  preset = "helix",
  defaults = {},
  spec = {
    {
      mode = { "n", "v" },
      { "<leader><tab>", group = "tabs" },
      { "<leader>c", group = "code" },
      { "<leader>d", group = "debug" },
      { "<leader>dp", group = "profiler" },
      { "<leader>f", group = "file/find" },
      { "<leader>g", group = "git" },
      { "<leader>gh", group = "hunks" },
      { "<leader>o", group = "OpenCode" },
      { "<leader>p", group = "Processes/Tasks" },
      { "<leader>q", group = "quit/session" },
      { "<leader>s", group = "search" },
      { "<leader>t", group = "test" },
      { "<leader>u", group = "ui", icon = { icon = " ", color = "cyan" } },
      { "<leader>x", group = "diagnostics/quickfix", icon = { icon = " ", color = "green" } },
      { "<leader>X", group = "Xcode" },
      { "[", group = "prev" },
      { "]", group = "next" },
      { "g", group = "goto" },
      { "gs", group = "surround" },
      { "z", group = "fold" },
      {
        "<leader>b",
        group = "buffer",
        expand = function()
          return require("which-key.extras").expand.buf()
        end,
      },
      {
        "<leader>w",
        group = "windows",
        proxy = "<c-w>",
        expand = function()
          return require("which-key.extras").expand.win()
        end,
      },
      { "gx", desc = "Open with system app" },
    },
  },
})

-- Keymaps
vim.keymap.set("n", "<leader>?", function()
  require("which-key").show({ global = false })
end, { desc = "Buffer Keymaps (which-key)" })

vim.keymap.set("n", "<c-w><space>", function()
  require("which-key").show({ keys = "<c-w>", loop = true })
end, { desc = "Window Hydra Mode (which-key)" })
