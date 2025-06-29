return {
  "ravitemer/mcphub.nvim",
  -- enabled = false,  -- Disable this plugin by default
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
  config = function()
    require("mcphub").setup({
      auto_approve = true,
    })
  end,
}
