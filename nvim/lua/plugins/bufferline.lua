-- Bufferline configuration
-- vim.pack version - no lazy loading

-- Add the plugin
vim.pack.add({"https://github.com/akinsho/bufferline.nvim.git"})

-- Configure the plugin
require("bufferline").setup({
  options = {
    close_command = function(n)
      local ok, snacks = pcall(require, "snacks")
      if ok then
        snacks.bufdelete(n)
      else
        vim.cmd("bdelete " .. n)
      end
    end,
    right_mouse_command = function(n)
      local ok, snacks = pcall(require, "snacks")
      if ok then
        snacks.bufdelete(n)
      else
        vim.cmd("bdelete " .. n)
      end
    end,
    diagnostics = "nvim_lsp",
    always_show_bufferline = false,
    offsets = {
      {
        filetype = "neo-tree",
        text = "Neo-tree",
        highlight = "Directory",
        text_align = "left",
      },
    },
  },
})

-- Fix bufferline when restoring a session
vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
  callback = function()
    vim.schedule(function()
      pcall(vim.cmd, "BufferLineRefresh")
    end)
  end,
})

-- Keymaps for bufferline
vim.keymap.set("n", "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", { desc = "Toggle Pin" })
vim.keymap.set("n", "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", { desc = "Delete Non-Pinned Buffers" })
vim.keymap.set("n", "<leader>br", "<Cmd>BufferLineCloseRight<CR>", { desc = "Delete Buffers to the Right" })
vim.keymap.set("n", "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", { desc = "Delete Buffers to the Left" })
vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "[B", "<cmd>BufferLineMovePrev<cr>", { desc = "Move buffer prev" })
vim.keymap.set("n", "]B", "<cmd>BufferLineMoveNext<cr>", { desc = "Move buffer next" })
