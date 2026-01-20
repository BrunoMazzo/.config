return {
  "pmizio/typescript-tools.nvim",
  enabled = false,
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  opts = {
    settings = {
      publish_diagnostic_on = "change"
    }
  },
}
