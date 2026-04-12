-- Overseer configuration
-- vim.pack version - no lazy loading

-- Add the plugin
vim.pack.add({"https://github.com/stevearc/overseer.nvim.git"})

-- Configure the plugin
require("overseer").setup({
  component_aliases = {
    default_neotest = {
      "on_output_summarize",
      "on_exit_set_status",
      "on_complete_notify",
      "on_complete_dispose",
    },
  },
  task_list = {
    keymaps = {
      ["s"] = "keymap.stop",
    },
  },
})

-- Keymaps
vim.keymap.set("n", "<leader>pt", "<cmd>OverseerToggle<cr>", { desc = "Toggle Task Manager" })
vim.keymap.set("n", "<leader>pr", "<cmd>OverseerRun<cr>", { desc = "Run Task" })
