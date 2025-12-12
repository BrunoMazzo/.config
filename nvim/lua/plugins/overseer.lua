return {
  "stevearc/overseer.nvim",
  keys = {
    {
      "<leader>pt",
      "<cmd>OverseerToggle<cr>",
      desc = "Toggle Task Manager",
    },
    {
      "<leader>pr",
      "<cmd>OverseerRun<cr>",
      desc = "Run Task",
    },
  },
  config = function(_, opts)
    local overseer = require("overseer").setup({
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
  end,
}
