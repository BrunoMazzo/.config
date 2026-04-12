-- nvim-dap-ui configuration
-- vim.pack version - no lazy loading

-- Add dependency first
vim.pack.add({"https://github.com/nvim-neotest/nvim-nio.git"})

-- Add the main plugin
vim.pack.add({"https://github.com/rcarriga/nvim-dap-ui.git"})

-- Configure the plugin
local dap = require("dap")
local dapui = require("dapui")

dapui.setup()

-- Auto open/close dapui
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open({})
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close({})
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close({})
end

-- Keymaps
vim.keymap.set("n", "<leader>du", function()
  dapui.toggle({})
end, { desc = "Dap UI" })
vim.keymap.set({ "n", "v" }, "<leader>de", function()
  dapui.eval()
end, { desc = "Eval" })
