return {
  "andythigpen/nvim-coverage",
  version = "*",
  config = function()
    require("coverage").setup({
      auto_reload = true,
    })
  end,
  keys = {
    {
      "<leader>uc",
      "<cmd>CoverageLoad<cr><cmd>CoverageToggle<cr>",
      desc = "Toggle Coverage",
    },
  },
}
