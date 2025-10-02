return {
  "stevearc/overseer.nvim",
  opts = {
    component_aliases = {
      default_neotest = {
        "on_output_summarize",
        "on_exit_set_status",
        "on_complete_notify",
        "on_complete_dispose",
      },
    },
  },
  keys = {
    {
      "<leader>Tt",
      "<cmd>OverseerToggle<cr>",
      desc = "Toggle Task Manager",
    },
    {
      "<leader>TT",
      "<cmd>OverseerToggle<cr>",
      desc = "Toggle Task Manager",
    },
    {
      "<leader>Tr",
      "<cmd>OverseerRun<cr>",
      desc = "Run Task",
    },
  },
}
