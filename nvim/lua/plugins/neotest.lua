return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    {
      "nvim-treesitter/nvim-treesitter", -- Optional, but recommended
    },
    {
      "fredrikaverpil/neotest-golang",
      version = "*", -- Optional, but recommended
      build = function()
        vim.system({ "go", "install", "gotest.tools/gotestsum@latest" }):wait() -- Optional, but recommended
      end,
      dependencies = {
        "leoluz/nvim-dap-go",
        "andythigpen/nvim-coverage", -- Added dependency
      },
    },
    "thenbe/neotest-playwright",
    "marilari88/neotest-vitest",
  },
  config = function(_, opts)
    local neotest_ns = vim.api.nvim_create_namespace("neotest")
    vim.diagnostic.config({
      virtual_text = {
        format = function(diagnostic)
          -- Replace newline and tab characters with space for more compact diagnostics
          local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
          return message
        end,
      },
    }, neotest_ns)

    ---@diagnostic disable-next-line: missing-fields
    require("neotest").setup({
      adapters = {
        require("neotest-golang")({
          go_test_args = { "-tags=integration", "-coverprofile=" .. vim.fn.getcwd() .. "/coverage.out" },
          runner = "go",
        }),
        require("neotest-playwright").adapter({
          options = {
            persist_project_selection = true,
            enable_dynamic_test_discovery = true,
            is_test_file = function(file_path)
              -- By default, only returns true if a file contains one of several file
              -- extension patterns. See default implementation here: https://github.com/thenbe/neotest-playwright/blob/53c7c9ad8724a6ee7d708c1224f9ea25fa071b61/src/discover.ts#L25-L47
              local result = file_path:find("%.spec%.[tj]sx?$") ~= nil or file_path:find("%.spec%.[tj]sx?$") ~= nil
              return result
            end,
          },
        }),
        require("neotest-vitest"),
      },
      -- status = { virtual_text = true },
      -- output_panel = { enabled = false },
      -- output = { open_on_run = false },
      -- quickfix = {
      --   enabled = false,
      --   open = function()
      --     require("trouble").open({ mode = "quickfix", focus = false })
      --   end,
      -- },
      discovery = { enabled = false, concurrent = 1 },
      -- running = {
      --   concurrent = true,
      -- },
    })
  end,
  keys = {
    {"<leader>t", "", desc = "+test"},
    { "<leader>tt", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File (Neotest)" },
    { "<leader>tT", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Run All Test Files (Neotest)" },
    { "<leader>tr", function() require("neotest").run.run() end, desc = "Run Nearest (Neotest)" },
    { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Run Last (Neotest)" },
    { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle Summary (Neotest)" },
    { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show Output (Neotest)" },
    { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle Output Panel (Neotest)" },
    { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop (Neotest)" },
    { "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Toggle Watch (Neotest)" },
  },
}
