-- Noice configuration
-- vim.pack version - no lazy loading

-- Add dependency first
vim.pack.add({"https://github.com/rcarriga/nvim-notify.git"})

-- Add the main plugin
vim.pack.add({"https://github.com/folke/noice.nvim.git"})

-- Configure the plugin
require("noice").setup({
  lsp = {
    progress = {
      enabled = false,
    },
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
  },
  routes = {
    {
      filter = {
        event = "msg_show",
        any = {
          { find = "%d+L, %d+B" },
          { find = "; after #%d+" },
          { find = "; before #%d+" },
        },
      },
      view = "mini",
    },
  },
  presets = {
    command_palette = true,
    long_message_to_split = true,
  },
})

-- Keymaps for noice
vim.keymap.set("n", "<leader>sn", "", { desc = "+noice" })
vim.keymap.set("c", "<S-Enter>", function()
  require("noice").redirect(vim.fn.getcmdline())
end, { desc = "Redirect Cmdline" })
vim.keymap.set("n", "<leader>snl", function()
  require("noice").cmd("last")
end, { desc = "Noice Last Message" })
vim.keymap.set("n", "<leader>snh", function()
  require("noice").cmd("history")
end, { desc = "Noice History" })
vim.keymap.set("n", "<leader>sna", function()
  require("noice").cmd("all")
end, { desc = "Noice All" })
vim.keymap.set("n", "<leader>snd", function()
  require("noice").cmd("dismiss")
end, { desc = "Dismiss All" })
vim.keymap.set("n", "<leader>snt", function()
  require("noice").cmd("pick")
end, { desc = "Noice Picker" })

-- Scroll mappings
local function scroll_forward()
  if not require("noice.lsp").scroll(4) then
    return "<c-f>"
  end
end

local function scroll_backward()
  if not require("noice.lsp").scroll(-4) then
    return "<c-b>"
  end
end

vim.keymap.set({ "i", "n", "s" }, "<c-f>", scroll_forward, { silent = true, expr = true, desc = "Scroll Forward" })
vim.keymap.set({ "i", "n", "s" }, "<c-b>", scroll_backward, { silent = true, expr = true, desc = "Scroll Backward" })
