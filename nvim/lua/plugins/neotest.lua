-- Neotest configuration
-- vim.pack version - no lazy loading

-- Add dependencies first
vim.pack.add({ "https://github.com/nvim-lua/plenary.nvim.git" })
vim.pack.add({ "https://github.com/antoinemadec/FixCursorHold.nvim.git" })
vim.pack.add({ "https://github.com/nvim-neotest/nvim-nio.git" })

-- Add neotest adapters
vim.pack.add({ "https://github.com/fredrikaverpil/neotest-golang.git" })
vim.pack.add({ "https://github.com/thenbe/neotest-playwright.git" })
vim.pack.add({ "https://github.com/marilari88/neotest-vitest.git" })

-- Add the main plugin
vim.pack.add({ "https://github.com/nvim-neotest/neotest.git" })

-- Optional: install gotestsum if not present (replaces lazy.nvim build hook)
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    if vim.fn.executable("gotestsum") == 0 then
      vim.notify("Installing gotestsum...", vim.log.levels.INFO)
      vim.system({ "go", "install", "gotest.tools/gotestsum@latest" }, {}, function(obj)
        if obj.code == 0 then
          vim.notify("gotestsum installed successfully", vim.log.levels.INFO)
        else
          vim.notify("Failed to install gotestsum: " .. (obj.stderr or ""), vim.log.levels.WARN)
        end
      end)
    end
  end,
})

-- Configure the plugin
require("neotest").setup({
  adapters = {
    require("neotest-golang")({
      go_test_args = { "-tags=integration,stripe", "-coverprofile=" .. vim.fn.getcwd() .. "/coverage.out" },
      runner = "go",
    }),
    require("neotest-playwright").adapter({
      options = {
        persist_project_selection = true,
        enable_dynamic_test_discovery = true,
        is_test_file = function(file_path)
          -- By default, only returns true if a file contains one of several file
          -- extension patterns. See default implementation here: https://github.com/thenbe/neotest-playwright/blob/53c7c9ad8724a6ee7d708c1224f9ea25fa071b61/src/discover.ts#L25-L47
          local result = file_path:find("%.spec%.[tj]sx?$") ~= nil or file_path:find("%.test%.[tj]sx?$") ~= nil
          return result
        end,
      },
    }),
    require("neotest-vitest"),
  },
  discovery = { enabled = false, concurrent = 1 },
})

-- Keymaps
vim.keymap.set("n", "<leader>t", "", { desc = "+test" })

vim.keymap.set("n", "<leader>tt", function()
  require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "Run File (Neotest)" })

vim.keymap.set("n", "<leader>tT", function()
  require("neotest").run.run(vim.uv.cwd())
end, { desc = "Run All Test Files (Neotest)" })

vim.keymap.set("n", "<leader>tr", function()
  require("neotest").run.run()
end, { desc = "Run Nearest (Neotest)" })

vim.keymap.set("n", "<leader>td", function()
  require("neotest").run.run({ strategy = "dap" })
end, { desc = "Debug Nearest (Neotest)" })

vim.keymap.set("n", "<leader>tl", function()
  require("neotest").run.run_last()
end, { desc = "Run Last (Neotest)" })

vim.keymap.set("n", "<leader>ts", function()
  require("neotest").summary.toggle()
end, { desc = "Toggle Summary (Neotest)" })

vim.keymap.set("n", "<leader>to", function()
  require("neotest").output.open({ enter = true, auto_close = true })
end, { desc = "Show Output (Neotest)" })

vim.keymap.set("n", "<leader>tO", function()
  require("neotest").output_panel.toggle()
end, { desc = "Toggle Output Panel (Neotest)" })

vim.keymap.set("n", "<leader>tS", function()
  require("neotest").run.stop()
end, { desc = "Stop (Neotest)" })

vim.keymap.set("n", "<leader>tw", function()
  require("neotest").watch.toggle(vim.fn.expand("%"))
end, { desc = "Toggle Watch (Neotest)" })
