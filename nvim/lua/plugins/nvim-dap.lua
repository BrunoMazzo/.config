-- nvim-dap configuration
-- vim.pack version - no lazy loading

-- Add the plugin
vim.pack.add({"https://github.com/mfussenegger/nvim-dap.git"})

-- Configure the plugin
local dap = require("dap")

-- Setup highlight for stopped line
vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

-- Configure JS/TS debug adapters
for _, adapter in pairs({ "pwa-node", "pwa-chrome" }) do
  dap.adapters[adapter] = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = {
      command = "js-debug-adapter",
      args = { "${port}" },
    },
  }
end

-- Keymaps
vim.keymap.set("n", "<leader>dB", function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Breakpoint Condition" })
vim.keymap.set("n", "<leader>db", function()
  dap.toggle_breakpoint()
end, { desc = "Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dc", function()
  dap.continue()
end, { desc = "Run/Continue" })
vim.keymap.set("n", "<leader>dC", function()
  dap.run_to_cursor()
end, { desc = "Run to Cursor" })
vim.keymap.set("n", "<leader>dg", function()
  dap.goto_()
end, { desc = "Go to Line (No Execute)" })
vim.keymap.set("n", "<leader>di", function()
  dap.step_into()
end, { desc = "Step Into" })
vim.keymap.set("n", "<leader>dj", function()
  dap.down()
end, { desc = "Down" })
vim.keymap.set("n", "<leader>dk", function()
  dap.up()
end, { desc = "Up" })
vim.keymap.set("n", "<leader>dl", function()
  dap.run_last()
end, { desc = "Run Last" })
vim.keymap.set("n", "<leader>do", function()
  dap.step_out()
end, { desc = "Step Out" })
vim.keymap.set("n", "<leader>dO", function()
  dap.step_over()
end, { desc = "Step Over" })
vim.keymap.set("n", "<leader>dP", function()
  dap.pause()
end, { desc = "Pause" })
vim.keymap.set("n", "<leader>dr", function()
  dap.repl.toggle()
end, { desc = "Toggle REPL" })
vim.keymap.set("n", "<leader>ds", function()
  dap.session()
end, { desc = "Session" })
vim.keymap.set("n", "<leader>dt", function()
  dap.terminate()
end, { desc = "Terminate" })
vim.keymap.set("n", "<leader>dw", function()
  require("dap.ui.widgets").hover()
end, { desc = "Widgets" })
