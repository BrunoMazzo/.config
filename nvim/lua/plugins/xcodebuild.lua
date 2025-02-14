local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
return {
  "wojciech-kulik/xcodebuild.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-tree.lua", -- (optional) to manage project files
    "stevearc/oil.nvim", -- (optional) to manage project files
    "nvim-treesitter/nvim-treesitter", -- (optional) for Quick tests support (required Swift parser)
  },
  config = function()
    require("xcodebuild").setup({
      show_build_progress_bar = false,
      logs = {
        auto_open_on_success_tests = false,
        auto_open_on_failed_tests = false,
        auto_open_on_success_build = false,
        auto_open_on_failed_build = false,
        auto_focus = false,
        auto_close_on_app_launch = true,
        only_summary = true,
        notify = function(message, severity)
          if vim.trim(message) ~= "" then
            vim.notify(message, severity, {
              id = "xcodebuild",
              opts = function(notif)
                notif.icon = spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
              end,
            })
          end
        end,
        notify_progress = function(message)
          if vim.trim(message) ~= "" then
            vim.notify(message, vim.log.levels.INFO, {
              id = "xcodebuild",
              opts = function(notif)
                notif.icon = spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
              end,
            })
          end
        end,
      },
      test_explorer = {
        enabled = true, -- enable Test Explorer
        auto_open = true, -- open Test Explorer when tests are started
        auto_focus = true, -- focus Test Explorer when opened
        open_command = "botright 42vsplit Test Explorer", -- command used to open Test Explorer, must create a buffer with "Test Explorer" name
        open_expanded = true, -- open Test Explorer with expanded classes
        success_sign = "✔", -- passed test icon
        failure_sign = "✖", -- failed test icon
        progress_sign = "…", -- progress icon (only used when animate_status=false)
        disabled_sign = "⏸", -- disabled test icon
        partial_execution_sign = "‐", -- icon for a class or target when only some tests were executed
        not_executed_sign = " ", -- not executed or partially executed test icon
        show_disabled_tests = false, -- show disabled tests
        animate_status = true, -- animate status while running tests
        cursor_follows_tests = true, -- moves cursor to the last test executed
      },
      code_coverage = {
        enabled = true,
      },
    })

    -- stylua: ignore start
    vim.keymap.set("n", "<leader>XP", "<cmd>XcodebuildPicker<cr>", { desc = "Show Xcodebuild Actions" })
    vim.keymap.set("n", "<leader>Xf", "<cmd>XcodebuildProjectManager<cr>", { desc = "Show Project Manager Actions" })

    vim.keymap.set("n", "<leader>Xb", "<cmd>XcodebuildBuild<cr>", { desc = "Build Project" })
    vim.keymap.set("n", "<leader>XB", "<cmd>XcodebuildBuildForTesting<cr>", { desc = "Build For Testing" })
    vim.keymap.set("n", "<leader>Xr", "<cmd>XcodebuildBuildRun<cr>", { desc = "Build & Run Project" })

    vim.keymap.set("n", "<leader>Xt", "<cmd>XcodebuildTest<cr>", { desc = "Run Tests" })
    vim.keymap.set("v", "<leader>Xt", "<cmd>XcodebuildTestSelected<cr>", { desc = "Run Selected Tests" })
    vim.keymap.set("n", "<leader>XT", "<cmd>XcodebuildTestClass<cr>", { desc = "Run This Test Class" })

    vim.keymap.set("n", "<leader>Xl", "<cmd>XcodebuildToggleLogs<cr>", { desc = "Toggle Xcodebuild Logs" })
    vim.keymap.set("n", "<leader>Xc", "<cmd>XcodebuildToggleCodeCoverage<cr>", { desc = "Toggle Code Coverage" })
    vim.keymap.set("n", "<leader>XC", "<cmd>XcodebuildShowCodeCoverageReport<cr>", { desc = "Show Code Coverage Report" })
    vim.keymap.set("n", "<leader>Xe", "<cmd>XcodebuildTestExplorerToggle<cr>", { desc = "Toggle Test Explorer" })
    vim.keymap.set("n", "<leader>Xs", "<cmd>XcodebuildFailingSnapshots<cr>", { desc = "Show Failing Snapshots" })

    vim.keymap.set("n", "<leader>Xd", "<cmd>XcodebuildSelectDevice<cr>", { desc = "Select Device" })
    vim.keymap.set("n", "<leader>Xp", "<cmd>XcodebuildSelectTestPlan<cr>", { desc = "Select Test Plan" })
    vim.keymap.set("n", "<leader>Xq", "<cmd>Telescope quickfix<cr>", { desc = "Show QuickFix List" })

    vim.keymap.set("n", "<leader>Xx", "<cmd>XcodebuildQuickfixLine<cr>", { desc = "Quickfix Line" })
    vim.keymap.set("n", "<leader>Xa", "<cmd>XcodebuildCodeActions<cr>", { desc = "Show Code Actions" })
  end,
}
